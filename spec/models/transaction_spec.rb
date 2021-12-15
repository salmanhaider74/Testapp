# == Schema Information
#
# Table name: transactions
#
#  id                 :bigint           not null, primary key
#  account_id         :bigint
#  order_id           :bigint
#  type               :string
#  status             :string
#  interest_cents     :integer          default(0), not null
#  interest_currency  :string           default("USD"), not null
#  fees_cents         :integer          default(0), not null
#  fees_currency      :string           default("USD"), not null
#  principal_cents    :integer          default(0), not null
#  principal_currency :string           default("USD"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  payment_id         :integer
#  number             :string
#
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  context 'create transactions for Vendor' do
    before do
      @vendor_account = create(:vendor_account)
      @transcation = build(:transaction, account: @vendor_account)
    end
  end
end
