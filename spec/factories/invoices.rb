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
FactoryBot.define do
  factory :invoice do
    customer { create(:customer) }
    amount { 2000.step(by: 2000, to: 500_000).to_a.sample }
    status { 'draft' }
    posted_date { Date.today }
    due_date { Date.today + 7.days }
  end
end
