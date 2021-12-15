# == Schema Information
#
# Table name: transactions
#
#  id                 :bigint           not null, primary key
#  account_id         :bigint
#  order_id           :bigint
#  type               :string
#  status             :string
#  interest_cents     :integer          default(0), not null
#  interest_currency  :string           default("USD"), not null
#  fees_cents         :integer          default(0), not null
#  fees_currency      :string           default("USD"), not null
#  principal_cents    :integer          default(0), not null
#  principal_currency :string           default("USD"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  payment_id         :integer
#  number             :string
#
FactoryBot.define do
  factory :transaction do
    interest { 0.06.step(by: 0.01, to: 0.2).to_a.sample }
    fees { 0.06.step(by: 0.01, to: 0.2).to_a.sample }
    principal { 5000.step(by: 5000, to: 500_000).to_a.sample }
    type { Transaction.type.values.sample }
    status { Transaction.status.values.sample }
    account

    factory :my_transaction do
    end
  end
end
