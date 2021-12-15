# == Schema Information
#
# Table name: invoices
#
#  id              :bigint           not null, primary key
#  customer_id     :bigint
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  status          :string
#  posted_date     :date
#  due_date        :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  number          :string
#  invoice_date    :date
#
class Invoice < ApplicationRecord
  include Rails.application.routes.url_helpers

  include Numerify
  extend Enumerize

  enumerize :status, in: [:draft, :pending, :paid], default: 'draft', predicates: true
  monetize :amount_cents, { greater_than: 0 }

  belongs_to :customer
  has_many :invoice_items, dependent: :delete_all
  has_many :invoice_payments

  has_one_attached :pdf

  validate :due_date_must_be_after_posted_date, if: ->(i) { i.posted_date.present? && i.due_date.present? }
  validate :invoice_item_amount

  before_create :attach_invoice_pdf, if: ->(i) { i.customer.default_payment_method.present? }

  def due_date_must_be_after_posted_date
    errors.add(:due_date, 'must be after posted time') if posted_date > due_date
  end

  def email_invoice
    InvoiceMailer.with({
      contact: customer.primary_contact,
      invoice: self,
    }).invoice_summary.deliver_later
    true
  end

  def url
    pdf.present? ? polymorphic_url(pdf, Rails.application.config.action_controller.default_url_options) : ''
  end

  def charge!(external_id = nil, payment_method: customer.default_payment_method, invoice_amount: amount)
    raise 'no payment_method found on customer account' if payment_method.nil?
    raise 'amount cannot be less than or equal to zero' unless invoice_amount.to_f.positive?
    raise 'valid external_id is required in case of payment_method invoice' if (external_id.nil? || external_id.empty?) && payment_method.invoice?
    raise 'this action will make invoice payments greater than invoice amount' if invoice_payments.map { |p| p.payment.amount_cents }.inject(0, &:+) + (invoice_amount.to_f * 100) > amount_cents

    Invoice.transaction do
      if payment_method.ach? || payment_method.plaid?
        payment_service = PaymentService::Service.new
        gateway_resp = payment_service.collect_payment(payment_method, invoice_amount)
        payment = Payment.create!(resource: customer, external_id: gateway_resp[:external_id], amount: invoice_amount, status: gateway_resp[:status], error_message: gateway_resp[:error], payment_method: payment_method)
      else
        payment = Payment.create!(resource: customer, external_id: external_id, amount: invoice_amount, status: 'processed', payment_method: payment_method)
      end
      invoice_payments.create!(payment: payment)
    end
  end

  def credit_account!(payment)
    amount_left = payment.amount
    invoice_items.where('amount_cents > amount_charged_cents').order('created_at ASC').each do |inv_item|
      Invoice.transaction do
        cr_amt = amount_left > inv_item.charge_left ? inv_item.charge_left : amount_left
        break if amount_left.zero?

        interest = cr_amt >= inv_item.payment_schedule_item.interest ? inv_item.payment_schedule_item.interest : cr_amt
        interest = inv_item.amount_charged >= interest ? Money.new(0) : interest - inv_item.amount_charged
        inv_item.payment_schedule_item.payment_schedule.account.credit!(cr_amt - interest, interest: interest, payment: payment, status: :posted)
        inv_item.amount_charged += cr_amt
        inv_item.save!
        amount_left -= cr_amt
      end
    end
    true
  end

  def attach_invoice_pdf
    self.pdf = ActiveStorage::Blob.create_and_upload!(
      io: File.open(InvoicePdf.generate_invoice_pdf(self)),
      filename: "#{number}.pdf",
      content_type: 'application/pdf'
    )
  end

  def post!
    raise 'invoice is already posted' if paid? || pending?

    update!(posted_date: Date.today, status: :pending)
    true
  end

  def formatted_amount
    amount.format
  end

  private

  def invoice_item_amount
    errors.add(:amount, 'should match sum of invoice items amount') if invoice_items.count.positive? && amount_cents != invoice_items.map(&:amount_cents).inject(0, &:+)
  end
end
