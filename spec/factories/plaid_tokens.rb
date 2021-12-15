# == Schema Information
#
# Table name: plaid_tokens
#
#  id            :bigint           not null, primary key
#  access_token  :string
#  item_id       :string
#  request_id    :string
#  account_id    :string
#  resource_type :string           not null
#  resource_id   :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :plaid_token do
    access_token { 'access-sandbox-574630b1-62ff-46d7-964c-6fcd489df83f' }
    item_id { 'mEZEpDmbZyS1JnWVGdjZsKro3xQVj5u79aVXk' }
    request_id { '7E2xgmPVsibjPPE' }
    association :resource, factory: :payment_method_plaid
  end
end
