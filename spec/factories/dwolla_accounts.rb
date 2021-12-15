# == Schema Information
#
# Table name: dwolla_accounts
#
#  id             :bigint           not null, primary key
#  resource_type  :string           not null
#  resource_id    :bigint           not null
#  is_master      :string
#  url            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  verified       :boolean          default(FALSE), not null
#  funding_source :string
#
FactoryBot.define do
  factory :dwolla_account do
    factory :customer_dwolla_account do
      association :resource, factory: :customer
      is_master { false }
      url { 'https://api-sandbox.dwolla.com/funding-sources/5f29ed95-733d-482f-9978-303b4180796a' }
    end

    factory :vendor_dwolla_account do
      association :resource, factory: :vendor
      is_master { false }
      url { 'https://api-sandbox.dwolla.com/funding-sources/5f29ed95-733d-482f-9978-303b4180796a' }
    end
  end
end
