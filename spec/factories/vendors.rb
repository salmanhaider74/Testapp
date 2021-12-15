# == Schema Information
#
# Table name: vendors
#
#  id          :bigint           not null, primary key
#  name        :string
#  duns_number :string
#  ein         :string
#  domain      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  number      :string
#
FactoryBot.define do
  factory :vendor do
    sequence(:name) { |n| "Test#{n}" }
    sequence(:domain) { |n| "domain#{n}.com" }
    ein { '00-0000000' }
    logo { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'logo.png'), 'image/png') }
    favicon { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'logo.png'), 'image/png') }
    contact_email { Faker::Internet.email }

    after(:create) do |vendor|
      create(:address, resource: vendor)
      create(:user, vendor: vendor)
    end
  end
end
