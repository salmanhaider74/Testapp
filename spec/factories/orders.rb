# == Schema Information
#
# Table name: orders
#
#  id                         :bigint           not null, primary key
#  status                     :string
#  billing_frequency          :string
#  start_date                 :date
#  end_date                   :date
#  approved_at                :datetime
#  declined_at                :datetime
#  customer_id                :bigint
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  number                     :string
#  workflow_steps             :jsonb
#  undewriting_engine_version :string           default("V1")
#  amount_cents               :integer          default(0), not null
#  amount_currency            :string           default("USD"), not null
#  term                       :decimal(, )
#  interest_rate              :decimal(5, 4)
#  interest_rate_subsidy      :decimal(5, 4)
#  signature_request_id       :string
#  has_form                   :boolean          default(FALSE), not null
#  product_id                 :bigint
#  application_sent           :boolean          default(FALSE), not null
#  loan_decision              :string
#  vartana_rating             :string
#  vartana_score              :decimal(4, 2)
#  manual_review              :boolean          default(FALSE), not null
#  fullcheck_consent          :boolean          default(FALSE), not null
#  financial_details          :jsonb            not null
#
FactoryBot.define do
  factory :order do
    transient do
      interest { 0.06.step(by: 0.01, to: 0.2).to_a.sample }
    end
    amount { 600_000 }
    interest_rate { interest }
    interest_rate_subsidy { interest - 0.02 }
    start_date { Date.today }
    end_date { Date.today + [12.month, 24.month, 36.month, 48.month, 60.month].sample }
    customer

    factory :custom_order do
      amount { 345_000 }
      interest_rate { 0.15  }
      interest_rate_subsidy { 0.15 - 0.02 }
      start_date { Date.today }
      end_date { Date.today + [12.month, 24.month, 36.month, 48.month, 60.month].sample }
    end

    after(:create) do |order, _evaluator|
      order.order_items = create_list(:order_item, 1, order: order, quantity: 1, unit_price_cents: order.amount_cents)
    end
  end
end
