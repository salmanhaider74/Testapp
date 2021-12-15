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
class PlaidToken < ApplicationRecord
  belongs_to :resource, polymorphic: true
end
