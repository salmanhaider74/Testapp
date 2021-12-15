# == Schema Information
#
# Table name: addresses
#
#  id            :bigint           not null, primary key
#  resource_type :string           not null
#  resource_id   :bigint           not null
#  street        :string
#  suite         :string
#  city          :string
#  state         :string
#  zip           :string
#  country       :string
#  is_default    :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :address do
    is_default { true }
    street { Faker::Address.street_address }
    suite { Faker::Address.building_number }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    country { 'US' }
    association :resource
  end
end
