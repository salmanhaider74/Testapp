# == Schema Information
#
# Table name: customers
#
#  id             :bigint           not null, primary key
#  vendor_id      :bigint
#  name           :string
#  duns_number    :string
#  encrypted_ein  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entity_type    :string
#  date_started   :date
#  number         :string
#  bill_cycle_day :integer
#  verified_at    :datetime
#
FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Acme#{n}" }
    sequence :ein do |n|
      "12-345678#{n}"
    end
    sequence(:duns_number)
    date_started { Faker::Date.in_date_period }
    entity_type { [:llc, :c_corp, :s_corp, :sole_proprietor].sample }
    reviewed { true }
    vendor
    after(:create) do |customer|
      create(:address, resource: customer)
    end

    factory :customer_contact do
      sequence(:name) { |n| "Acme#{n}" }
      sequence :ein do |n|
        "12-345678#{n}"
      end
      sequence(:duns_number)
      date_started { Faker::Date.in_date_period }
      entity_type { [:llc, :c_corp, :s_corp, :sole_proprietor].sample }
      vendor
      after(:create) do |customer|
        create(:address, resource: customer)
        create(:contact, customer: customer, primary: true)
      end
    end
  end
end
