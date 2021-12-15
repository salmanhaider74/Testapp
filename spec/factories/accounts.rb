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
FactoryBot.define do
  factory :account do
    factory :customer_account do
      association :resource, factory: :customer
      balance { 0 }
      order
    end

    factory :vendor_account do
      association :resource, factory: :vendor
      balance { 0 }
    end
  end
end
