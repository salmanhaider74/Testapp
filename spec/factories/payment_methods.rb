# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
#  resource_type            :string           not null
#  resource_id              :bigint           not null
#  is_default               :boolean          default(TRUE)
#  payment_mode             :string
#  account_name             :string
#  account_type             :string
#  routing_number           :string
#  encrypted_account_number :string
#  contact_name             :string
#  phone                    :string
#  email                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank                     :string
#  funding_source           :string
#  verified                 :boolean          default(FALSE), not null
#
FactoryBot.define do
  factory :payment_method do
    is_default { [true, false].sample }

    factory :payment_method_ach do
      association :resource, factory: [:vendor, :customer].sample
      payment_mode { 'ach' }
      bank { Faker::Bank.name }
      account_name { Faker::Name.name }
      account_type { [:checking, :savings].sample }
      routing_number { Faker::Bank.routing_number }
      account_number { Faker::Bank.iban }
      after(:create) do |payment_method|
        create(:address, resource: payment_method)
      end
    end

    factory :payment_method_invoice do
      association :resource, factory: [:vendor, :customer].sample
      payment_mode { 'invoice' }
      contact_name { Faker::Name.name }
      phone { Faker::PhoneNumber.cell_phone_in_e164 }
      email { Faker::Internet.email }
      after(:create) do |payment_method|
        create(:address, resource: payment_method)
      end
    end

    factory :payment_method_plaid do
      association :resource, factory: [:vendor, :customer].sample
      payment_mode { 'plaid' }
    end
  end
end
