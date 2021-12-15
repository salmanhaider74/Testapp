# == Schema Information
#
# Table name: products
#
#  id                                  :bigint           not null, primary key
#  vendor_id                           :bigint           not null
#  name                                :string
#  is_active                           :boolean          default(TRUE)
#  number                              :string
#  min_interest_rate_subsidy           :decimal(5, 4)
#  max_interest_rate_subsidy           :decimal(5, 4)
#  min_initial_loan_amount_cents       :integer          default(0), not null
#  min_initial_loan_amount_currency    :string           default("USD"), not null
#  min_subsequent_loan_amount_cents    :integer          default(0), not null
#  min_subsequent_loan_amount_currency :string           default("USD"), not null
#  max_loan_amount_cents               :integer          default(0), not null
#  max_loan_amount_currency            :string           default("USD"), not null
#  pricing_schema                      :jsonb            not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    is_active { true }
    min_interest_rate_subsidy { 0.001 }
    max_interest_rate_subsidy { 1 }
    min_initial_loan_amount { 10 }
    min_subsequent_loan_amount { 10 }
    max_loan_amount { 10_000_000 }
    pricing_schema { JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'pricing_schema.json'))).to_json }
    vendor
  end
end
