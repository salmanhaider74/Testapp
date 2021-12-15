# == Schema Information
#
# Table name: orders
#
#  id                         :bigint           not null, primary key
#  status                     :string
#  billing_frequency          :string
#  start_date                 :date
#  end_date                   :date
#  approved_at                :datetime
#  declined_at                :datetime
#  customer_id                :bigint
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  number                     :string
#  workflow_steps             :jsonb
#  undewriting_engine_version :string           default("V1")
#  amount_cents               :integer          default(0), not null
#  amount_currency            :string           default("USD"), not null
#  term                       :decimal(, )
#  interest_rate              :decimal(5, 4)
#  interest_rate_subsidy      :decimal(5, 4)
#  signature_request_id       :string
#  has_form                   :boolean          default(FALSE), not null
#  product_id                 :bigint
#  application_sent           :boolean          default(FALSE), not null
#  loan_decision              :string
#  vartana_rating             :string
#  vartana_score              :decimal(4, 2)
#  manual_review              :boolean          default(FALSE), not null
#  fullcheck_consent          :boolean          default(FALSE), not null
#  financial_details          :jsonb            not null
#
class Order < ApplicationRecord
  include Rails.application.routes.url_helpers

  DEFAULT_APP_DAYS = 3.days.freeze
  SIZE_RANGES = [
    { label: '0 - $1k', min: 0, max: 100_000 },
    { label: '$1K - $10K', min: 100_000, max: 1_000_000 },
    { label: '$10K - $50K', min: 1_000_000, max: 5_000_000 },
    { label: '$50K - $250K', min: 5_000_000, max: 25_000_000 },
    { label: '$250K - $500K', min: 25_000_000, max: 500_000 },
    { label: '$500K+', min: 50_000_000, max: Float::INFINITY }
  ].freeze

  include Numerify
  extend Enumerize

  enumerize :status, in: [:precheck, :fullcheck, :application, :checkout, :agreement, :financed], default: 'precheck', predicates: true
  enumerize :loan_decision, in: [:pending, :declined, :approved], default: 'pending', predicates: true

  enumerize :billing_frequency, in: [:monthly], default: 'monthly', predicates: true
  monetize :amount_cents, { greater_than: 0 }

  attr_accessor :summary_viewed, :start_date_validation, :interest_percentage, :interest_subsidy_percentage

  belongs_to :customer
  belongs_to :user, optional: true
  has_many :order_items, inverse_of: :order
  has_many :sessions
  has_many :personal_guarantees
  has_many :documents
  has_many :transactions
  has_one :account
  has_one :vendor, through: :customer
  has_one_attached :agreement
  belongs_to :product

  validates :customer_id, presence: true
  validates :start_date, :end_date, :interest_rate, :amount, frozen: true, if: :frozen?
  validates :term, :approved_at, :declined_at, :interest_rate_subsidy, frozen: true, if: :frozen?
  validates :start_date, :end_date, presence: true
  # validates :term, numericality: { greater_than: 0 }
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_rate_subsidy, numericality: { greater_than_or_equal_to: 0 }
  validate :order_items_amount
  validate :order_amount
  validate :order_interest_rate_subsidy
  validate :validate_financial_details
  validate :validate_start_date, if: ->(i) { i.start_date_validation == 'true' }

  accepts_nested_attributes_for :order_items, allow_destroy: true

  before_validation :set_vendor_fields
  before_save :set_status_timestamps, if: :loan_decision_changed?
  before_create :set_workflow_steps
  after_commit :pull_dnb_data, on: :create
  after_commit :pull_experian_data,
               if: proc { |record|
                 (record.previous_changes.key?(:status) &&
                 record.previous_changes[:status].first != record.previous_changes[:status].last &&
                 record.previous_changes[:status].last == 'fullcheck') ||
                   (record.previous_changes.key?(:fullcheck_consent) &&
                   record.previous_changes[:fullcheck_consent].first != record.previous_changes[:fullcheck_consent].last &&
                   record.previous_changes[:fullcheck_consent].last == true)
               }
  after_commit :run_financial_analysis!,
               if: proc { |record|
                 record.previous_changes.key?(:financial_details) &&
                   record.previous_changes[:financial_details].first != record.previous_changes[:financial_details].last &&
                   record.previous_changes[:financial_details].last != {}
               }
  after_commit :notification_emails

  scope :credit_review, -> { where(status: [:processing]) }
  scope :ops_review, -> { where(status: [:approved, :checkout, :agreement]) }
  scope :amount_between, ->(min, max) { where(amount_cents: min..max) }

  def pg_complete?
    total_pgs    = personal_guarantees.count
    accepted_pgs = personal_guarantees.accepted.count
    total_pgs.positive? && total_pgs == accepted_pgs
  end

  def underwrite!(contact)
    klass = "Underwriting::Engine::#{undewriting_engine_version}".constantize
    klass.new(contact, self).execute
  end

  def send_application!
    raise 'record should be persisted' unless id?

    session = Session.active.find_by(resource: customer.primary_contact, order_id: id)
    if session.present?
      session.update!(expires_at: DEFAULT_APP_DAYS.from_now)
    else
      session = Session.create!(resource: customer.primary_contact, order_id: id, expires_at: DEFAULT_APP_DAYS.from_now)
    end
    mailer = ContactMailer.with({ contact: session.resource, session: session })
    session.order.status == 'application' ? mailer.order_application.deliver_later : mailer.checkout_order.deliver_later
    true
  end

  def finance!
    raise 'cannot be called on an already financed order' if financed?

    transaction do
      cust_acct = Account.create(resource: customer, order: self)
      cust_acct.debit!(amount, status: :posted, order: self)
      vendor.account.credit!(advance, fees: discount, status: :posted, order: self)
      PaymentSchedule.create_from_order!(self)
      update!(status: :financed)
      customer.update!(bill_cycle_day: start_date.day) if customer.bill_cycle_day.nil?
    end
  end

  def checkout!
    raise 'order items not found' unless order_items.count.positive?

    update!(status: 'checkout', manual_review: false)
    underwrite!(customer.primary_contact)
  end

  def run_financial_analysis!
    update!(manual_review: false)
    underwrite!(customer.primary_contact)
  end

  def frozen?
    status_was == 'financed' || (status_was.nil? && financed?)
  end

  def finance_calculator
    @finance_calculator = Finance.new(
      amount: amount,
      rate: interest_rate,
      rate_subsidy: interest_rate_subsidy,
      bill_day: customer.try(:bill_cycle_day),
      start_date: start_date,
      end_date: end_date
    )
    @finance_calculator.calculate
    @finance_calculator
  end

  def documents_complete?
    documents.where(type: :bank_statement).any? && documents.where(type: :tax_return).any?
  end

  def document_of_type?(document_type)
    documents.where(type: document_type).any?
  end

  def advance
    amount - discount
  end

  def interest
    finance_calculator.interest
  end

  def discount
    finance_calculator.fees
  end

  def payment
    finance_calculator.payment
  end

  def schedule
    finance_calculator.schedule
  end

  def num_pmts
    finance_calculator.num_pmts
  end

  def customer_interest_rate
    interest_rate * (1 - interest_rate_subsidy)
  end

  def formatted_amount
    amount.format
  end

  def formatted_fee
    discount.format
  end

  def formatted_fee_percentage
    "#{((discount / amount) * 100).round(2)}%"
  end

  def formatted_payment
    order_items.map(&:summary_amount).inject(Money.new(0), &:+).format
  end

  def signature_url
    signature_request_id.present? ? Signature.create_signature_request_url(signature_request_id) : ''
  end

  def generate_agreement
    File.open(Agreement.generate_order_summary(self))
  end

  def financed_at
    account.try(:created_at)
  end

  def suggested_loan_decision
    suggested_loan_decision = 'pending'
    case vartana_rating
    when 'prime', 'near_prime', 'sub_prime'
      suggested_loan_decision = 'approved'
    when 'missing'
      suggested_loan_decision = 'pending'
    when 'declined'
      suggested_loan_decision = 'declined'
    end

    suggested_loan_decision
  end

  def credit_limit
    limit = amount
    case vartana_rating
    when 'prime'
      limit *= 1.2
    when 'near_prime'
      limit *= 1.0
    when 'sub_prime'
      limit *= 0.8
    when 'declined', 'missing', nil
      limit *= 0.0
    end

    limit
  end

  def formatted_credit_limit
    credit_limit.format
  end

  def validate_financial_details
    self.financial_details = JSON.parse(financial_details) if financial_details.instance_of?(String)
  rescue JSON::ParserError
    errors.add(:financial_details, 'should be a valid json')
  end

  def annual_revenue
    Money.new(financial_details['annual_revenue']) * 100
  end

  def annual_net_operating_income
    Money.new(financial_details['annual_net_operating_income']) * 100
  end

  def annual_debt_service
    debt_service_month1 = Money.new(financial_details.dig('month1', 'debt_service')) * 100
    debt_service_month2 = Money.new(financial_details.dig('month2', 'debt_service')) * 100
    debt_service_month3 = Money.new(financial_details.dig('month3', 'debt_service')) * 100
    (((debt_service_month1 + debt_service_month2 + debt_service_month3) / 3) * 12) + payment
  end

  def dscr
    annual_net_operating_income / annual_debt_service
  end

  def pull_middesk
    if customer.middesk_id.nil?
      middesk_client = Underwriting::Processors::Middesk::Client.new
      middesk_id = middesk_client.create_business(customer.name, customer.default_address)
      customer.update!(middesk_id: middesk_id) unless middesk_id.empty?
      PullMiddeskReport.set(wait_until: 10.minutes.from_now).perform_later(id)
    else
      PullMiddeskReport.perform_now(id)
    end
  end

  def notification_emails
    mailer = VendorMailer.with({ order: self })
    if saved_change_to_attribute?(:status)
      case status
      when 'fullcheck'
        if suggested_loan_decision == 'approved' && vendor.pre_approved_email && !fullcheck_consent
          mailer.order_preapproved.deliver_later
        elsif vendor.not_approved_require_fullcheck_email && !fullcheck_consent
          mailer.order_not_approved_need_consent_fullcheck.deliver_later
        end
      when 'application'
        mailer.need_financial_review.deliver_later if vendor.need_financial_review_email
      when 'checkout'
        mailer.checkout_ready.deliver_later if vendor.checkout_ready_email
      when 'financed'
        mailer.order_complete.deliver_later if vendor.order_financed_email
      end
    end
    return unless saved_change_to_attribute?(:loan_decision)

    case loan_decision
    when 'approved'
      mailer.need_sales_order.deliver_later if vendor.need_sales_order_email
    when 'declined'
      mailer.order_declined.deliver_later if vendor.order_declined_email
    end
  end

  def user_documents
    docs = []
    documents.where(type: [:order_form, :funding_invoice]).each do |doc|
      next unless doc.document.attached?

      docs << {
        'id': doc.id,
        'type': doc.type,
        'url': polymorphic_url(doc.document, Rails.application.config.action_controller.default_url_options),
      }
    end

    if agreement.attached?
      docs << {
        'id': 0,
        'type': 'agreement',
        'url': polymorphic_url(agreement, Rails.application.config.action_controller.default_url_options),
      }
    end

    docs
  end

  private

  def order_interest_rate_subsidy
    return unless interest_rate_subsidy > product.max_interest_rate_subsidy || interest_rate_subsidy < product.min_interest_rate_subsidy

    errors.add(:interest_rate_subsidy, 'should be in between active product range of a vendor')
    errors.add(:interest_subsidy_percentage, 'should be in between active product range of a vendor')
  end

  def order_amount
    errors.add(:amount, 'should be greater than minimum loan amount for a vendor') if (customer.orders.where(status: :financed).count < 1 && amount < product.min_initial_loan_amount) || (customer.orders.where(status: :financed).count >= 1 && amount < product.min_subsequent_loan_amount) || amount > product.max_loan_amount
  end

  def pull_dnb_data
    PullDnbReport.set(wait_until: 2.minutes.from_now).perform_later(id)
  end

  def pull_experian_data
    PullExperianReport.perform_later(id) if status == 'fullcheck' && fullcheck_consent
  end

  def set_status_timestamps
    self.approved_at = Time.now.utc if approved? && loan_decision_was != 'approved'
    self.declined_at = Time.now.utc if declined? && loan_decision_was != 'declined'
  end

  def validate_start_date
    errors.add(:start_date, 'cannot be in past') if start_date.present? && start_date < Time.now.to_date
  end

  def set_workflow_steps
    self.workflow_steps = {
      steps: [],
    }
    underwrite!(customer.primary_contact)
  end

  def order_items_amount
    amt = order_items.sum(&:amount)
    errors.add(:amount, 'should match sum of order items amount') if amt.positive? && amount != amt
  end

  def set_vendor_fields
    self.product_id = vendor.product.id if product_id.nil? && vendor.product.present?
    self.interest_rate = BigDecimal(0.1, 4) unless interest_rate.present? # its hacky need to change it.
    self.interest_rate_subsidy = interest_subsidy_percentage.to_f / 100 if interest_subsidy_percentage.present?

    self.term = finance_calculator.term
    self.interest_rate = vendor.product.interest_rate(vartana_rating, finance_calculator.term.to_f) if vartana_rating.present? && !%w[declined missing].include?(vartana_rating)
  end
end
