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
require 'rails_helper'

RSpec.describe PlaidToken, type: :model do
  context 'validation' do
    before do
      @plaid_token = create(:plaid_token)
    end

    it 'should contain plaid tokens' do
      expect(@plaid_token).to be_valid
    end
  end
end
