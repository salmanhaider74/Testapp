# == Schema Information
#
# Table name: accounts
#
#  id               :bigint           not null, primary key
#  resource_type    :string           not null
#  resource_id      :bigint           not null
#  order_id         :bigint
#  balance_cents    :integer          default(0), not null
#  balance_currency :string           default("USD"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  context 'debit! and credit!' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer)
      @order.finance!
      @cust_account = @order.account
      @vend_account = @vendor.account
    end

    it 'it should check debit!' do
      expect(@cust_account.reload.balance).to eq(-1 * @order.amount)
    end

    it 'it should check credit!' do
      @cust_account.reload.debit!((Money.new(1000)))
      @cust_account.credit!(Money.new(100))
      expect(@cust_account.balance).to eq(-1 * (@order.amount + Money.new(900)))
    end
  end

  context 'update_balance' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer)
      @order.finance!
      @cust_account = @order.account
    end

    it 'it should check balance sheet of account' do
      expect(@cust_account.balance).to eq(-1 * @order.amount)
    end
  end
end
