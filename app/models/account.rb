# == Schema Information
#
# Table name: accounts
#
#  id               :bigint           not null, primary key
#  resource_type    :string           not null
#  resource_id      :bigint           not null
#  order_id         :bigint
#  balance_cents    :integer          default(0), not null
#  balance_currency :string           default("USD"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Account < ApplicationRecord
  monetize :balance_cents

  has_many :transactions
  has_many :payment_schedules
  belongs_to :resource, polymorphic: true
  belongs_to :order, optional: true

  def payment_schedule
    payment_schedules.where(status: :active).order('version DESC').last
  end

  def debit!(principal, fees: 0, interest: 0, status: :pending, order: nil, payment: nil)
    transaction do
      transactions.create!({
        type: :debit,
        status: status,
        fees: fees,
        principal: principal,
        interest: interest,
        order: order,
        payment: payment,
      })
      update_balance!
    end
  end

  def credit!(principal, fees: 0, interest: 0, status: :pending, order: nil, payment: nil)
    transaction do
      transactions.create!({
        type: :credit,
        status: status,
        fees: fees,
        principal: principal,
        interest: interest,
        order: order,
        payment: payment,
      })
      update_balance!
    end
  end

  def pending_payment_schedule_items(invoice_date = Date.today)
    skip_ids = payment_schedule.payment_schedule_items.joins(:invoice_item).where('payment_schedule_items.due_date <= ?', invoice_date).map(&:id)
    payment_schedule.payment_schedule_items.where('payment_schedule_items.due_date <= ?', invoice_date).where.not(id: skip_ids)
  end

  private

  def update_balance!
    debits = transactions.debit.sum(&:principal)
    credits = transactions.credit.sum(&:principal)
    update!(balance: credits - debits)
  end
end
