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
FactoryBot.define do
  factory :payment_schedule_item do
    principal { 5000.step(by: 5000, to: 500_000).to_a.sample }
    interest { 0.06.step(by: 0.01, to: 0.2).to_a.sample }
    due_date { Date.today }
    payment_schedule
  end
end
