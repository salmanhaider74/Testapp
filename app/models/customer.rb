# == Schema Information
#
# Table name: customers
#
#  id             :bigint           not null, primary key
#  vendor_id      :bigint
#  name           :string
#  duns_number    :string
#  encrypted_ein  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entity_type    :string
#  date_started   :date
#  number         :string
#  bill_cycle_day :integer
#  verified_at    :datetime
#
class Customer < ApplicationRecord
  include Addressify
  include Numerify
  include Encryptable
  extend Enumerize

  has_paper_trail

  has_many :contacts
  has_many :orders
  has_many :documents
  has_many :payments
  has_many :accounts, as: :resource
  has_many :payment_methods, as: :resource
  belongs_to :vendor
  has_many :invoices
  has_one  :dwolla_account, as: :resource

  after_commit :verify_business, if: ->(i) { i.verified_at.nil? }

  enumerize :entity_type, in: [:llc, :c_corp, :s_corp, :sole_proprietor], predicates: true

  encrypts :ein, mask: 4

  validates :name, presence: true

  def owners
    contacts.where(role: :owner)
  end

  def status
    orders.count.positive? ? 'active' : 'inactive'
  end

  def primary_contact
    contacts.where(primary: true).first
  end

  def complete?
    name && duns_number? && reviewed? && default_address.present? && default_address.complete?
  end

  def default_payment_method
    payment_methods.where(is_default: true).first
  end

  def amount
    orders.map(&:amount).inject(0, &:+)
  end

  def discount
    orders.map(&:discount).inject(0, &:+)
  end

  def formatted_amount
    amount.zero? ? Money.new(0).format : amount.format
  end

  def formatted_fee
    discount.zero? ? Money.new(0).format : discount.format
  end

  def formatted_fee_percentage
    amount.zero? ? '0%' : "#{((discount / amount) * 100).round(2)}%"
  end

  def payment_schedule_items
    return [] unless accounts.present?

    accounts.map(&:payment_schedule).map(&:payment_schedule_items).inject([], &:+).sort_by(&:due_date)
  end

  def complete_order_end_date
    orders.where(status: :complete).order(created_at: :asc).first.try(:end_date)
  end

  def create_invoice!(invoice_date = Date.today)
    pending_items = []
    accounts.each do |acc|
      items = acc.pending_payment_schedule_items(invoice_date)
      pending_items.append(items)
    end
    pending_items.flatten!
    return false if pending_items.empty?

    invoice = invoices.create(invoice_date: invoice_date)
    due_date = Time.now - Time.now.to_i # 1970

    pending_items.each do |pending_item|
      invoice.invoice_items.create!(get_invoice_items(pending_item))
      due_date = pending_item.due_date if pending_item.due_date > due_date
    end

    invoice.update!(amount: invoice.invoice_items.sum(&:amount), due_date: due_date)

    true
  end

  private

  def verify_business
    VerifyBusiness.perform_later(id)
  end

  def get_invoice_items(schd_item)
    order = schd_item.order
    order.order_items.map do |order_item|
      {
        amount: order_item.summary_amount,
        name: order_item.name,
        description: order_item.description,
        payment_schedule_item: schd_item,
        order_item: order_item,
      }
    end
  end
end
