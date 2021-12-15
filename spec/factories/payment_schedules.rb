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
FactoryBot.define do
  factory :payment_schedule do
    term { [12, 24, 36, 48, 60].sample }
    billing_frequency { Order.billing_frequency.values.sample }
    interest_rate { 0.06.step(by: 0.01, to: 0.2).to_a.sample }
    start_date { Date.today }
    end_date { Date.today + 1.year }
    account
  end
end
