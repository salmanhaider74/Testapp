# == Schema Information
#
# Table name: payment_schedules
#
#  id                :bigint           not null, primary key
#  account_id        :bigint
#  version           :integer          default(1)
#  status            :string
#  term              :decimal(, )
#  start_date        :date
#  end_date          :date
#  billing_frequency :string
#  interest_rate     :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class PaymentSchedule < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [:draft, :disabled, :active], predicates: true

  has_many :payment_schedule_items
  belongs_to :account
  has_one :order, through: :account

  def self.create_from_order!(order)
    transaction do
      pmt_schdl = PaymentSchedule.create!({
        account: order.account,
        status: :active,
        term: order.term,
        start_date: order.start_date,
        end_date: order.end_date,
        billing_frequency: order.billing_frequency,
        interest_rate: order.customer_interest_rate,
      })

      items = order.schedule.map do |schd_item|
        {
          interest: schd_item.interest,
          principal: schd_item.principal,
          due_date: schd_item.start_date,
          fees: schd_item.fees,
          start_balance: schd_item.start_balance,
        }
      end
      pmt_schdl.payment_schedule_items.create!(items)
    end
  end
end
