# == Schema Information
#
# Table name: sessions
#
#  id             :bigint           not null, primary key
#  resource_type  :string           not null
#  resource_id    :bigint           not null
#  token          :string           not null
#  expires_at     :datetime         not null
#  last_active_at :datetime
#  sign_in_ip     :inet
#  current_ip     :inet
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  order_id       :bigint
#
FactoryBot.define do
  factory :session do
    factory :user_session do
      association :resource, factory: :user
    end

    factory :contact_session do
      association :resource, factory: :contact
    end
  end
end
