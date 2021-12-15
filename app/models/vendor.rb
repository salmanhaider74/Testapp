# == Schema Information
#
# Table name: vendors
#
#  id          :bigint           not null, primary key
#  name        :string
#  duns_number :string
#  ein         :string
#  domain      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  number      :string
#
class Vendor < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Addressify
  include Numerify

  DOMAIN_REGEX = /\A^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$\z/.freeze
  EMAIL_REGEX  = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  has_many :users
  has_many :customers
  has_many :contacts, through: :customers
  has_many :orders, through: :customers
  has_many :payments, as: :resource
  has_one  :account, as: :resource
  has_one  :dwolla_account, as: :resource
  has_many :payment_methods, as: :resource
  has_many :transactions, through: :account
  has_one_attached :logo
  has_one_attached :favicon
  has_many :products
  has_one :product, -> { where(is_active: true) }, class_name: 'Product'

  jsonb_accessor :email_preferences,
                 pre_approved_email: [:boolean, { default: true }],
                 not_approved_require_fullcheck_email: [:boolean, { default: true }],
                 need_financial_review_email: [:boolean, { default: true }],
                 need_sales_order_email: [:boolean, { default: true }],
                 checkout_ready_email: [:boolean, { default: true }],
                 agreement_signed_need_invoice_email: [:boolean, { default: true }],
                 order_financed_email: [:boolean, { default: true }],
                 order_declined_email: [:boolean, { default: true }]

  validates :name, :domain, :logo, :favicon, :contact_email, presence: true
  validates :domain, format: { with: DOMAIN_REGEX }
  validates :contact_email, format: { with: EMAIL_REGEX }

  after_create :create_account

  def from_email
    domain = Rails.env.staging? ? 's.vartana.co' : 'vartana.co'
    "#{name} <financing@#{domain}>"
  end

  def logo_url
    logo.present? ? polymorphic_url(logo, Rails.application.config.action_controller.default_url_options) : ''
  end

  def favicon_url
    favicon.present? ? polymorphic_url(favicon, Rails.application.config.action_controller.default_url_options) : ''
  end

  def payout!(external_id = nil, payment_method: default_payment_method, balance_amount: account.balance)
    raise 'no payment_method found on vendor account' if payment_method.nil?
    raise 'amount cannot be less than or equal to zero' unless balance_amount.to_i.positive?
    raise 'valid external_id is required in case of payment_method invoice' if (external_id.nil? || external_id.empty?) && payment_method.invoice?
    raise 'this action will make account balance negative' if account.balance.cents < Money.new(balance_amount.to_f * 100).cents

    Vendor.transaction do
      if payment_method.ach?
        payment_service = PaymentService::Service.new
        gateway_resp = payment_service.payout(self, balance_amount, payment_method)
        payment = Payment.create!(resource: self, external_id: gateway_resp[:external_id], amount: balance_amount, status: gateway_resp[:status], error_message: gateway_resp[:error], payment_method: payment_method)
      else
        payment = Payment.create!(resource: self, external_id: external_id, amount: balance_amount, status: 'processed', payment_method: payment_method)
      end
      account.debit!(payment.amount, status: :posted, payment: payment)
    end
  end

  def default_payment_method
    payment_methods.where(is_default: true).first
  end

  private

  def create_account
    Account.create!(resource: self)
  end
end
