# == Schema Information
#
# Table name: payment_schedule_items
#
#  id                  :bigint           not null, primary key
#  payment_schedule_id :bigint
#  principal_cents     :integer          default(0), not null
#  principal_currency  :string           default("USD"), not null
#  interest_cents      :integer          default(0), not null
#  interest_currency   :string           default("USD"), not null
#  due_date            :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fees_cents          :integer          default(0), not null
#  fees_currency       :string           default("USD"), not null
#
class PaymentScheduleItem < ApplicationRecord
  monetize :principal_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :interest_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :fees_cents, numericality: { greater_than_or_equal_to: 0 }
  monetize :start_balance_cents, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :payment_schedule
  has_one :order, through: :payment_schedule
  has_one :invoice_item
  has_one :invoice, through: :invoice_item
  has_one :account, through: :payment_schedule

  validates :due_date, presence: true

  def end_balance
    val = start_balance - principal
    val.zero? ? Money.new(0, start_balance.currency.iso_code).format : val.format
  end

  def payment
    principal + interest + fees
  end

  def formatted_payment
    payment.format
  end

  def status
    if invoice.present? && invoice.paid?
      'Paid'
    elsif Date.today < due_date
      'Upcoming'
    elsif Date.today == due_date
      'Due'
    else
      'Late'
    end
  end
end
