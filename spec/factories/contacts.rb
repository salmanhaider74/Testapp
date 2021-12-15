# == Schema Information
#
# Table name: contacts
#
#  id            :bigint           not null, primary key
#  customer_id   :bigint
#  first_name    :string
#  last_name     :string
#  phone         :string
#  email         :string
#  role          :string
#  encrypted_ssn :string
#  dob           :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  primary       :boolean          default(FALSE), not null
#  ownership     :decimal(, )
#  deleted_at    :datetime
#  inquiry_id    :string
#  verified_at   :datetime
#
FactoryBot.define do
  factory :contact do
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Doe#{n}" }
    email { Faker::Internet.email }
    ownership { [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0].sample }
    phone { '+13147123232' }
    role { 'owner' }
    ssn { '123-12-1234' }
    reviewed { true }
    dob { Faker::Date.in_date_period }
    customer
    after(:create) do |contact|
      create(:address, resource: contact)
    end
  end
end
