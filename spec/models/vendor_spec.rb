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
require 'rails_helper'

RSpec.describe Vendor, type: :model do
  context 'validations and methods' do
    before do
      @vendor = build(:vendor, name: 'Test', domain: 'test')
    end

    it 'should validate domain name' do
      expect(@vendor.valid?).to be false

      @vendor.domain = 'ABC123'
      expect(@vendor.valid?).to be false

      @vendor.domain = 'abc-123'
      expect(@vendor.valid?).to be false

      @vendor.domain = 'abc123'
      expect(@vendor.valid?).to be false

      @vendor.domain = 'example.com'
      expect(@vendor.valid?).to be true

      @vendor.domain = 'hello.museum'
      expect(@vendor.valid?).to be true
    end

    it 'should return from_email' do
      expect(@vendor.from_email).to eq('Test <financing@Testapp.co>')
    end

    it 'should have an account' do
      @vendor.domain = 'hello.museum'
      @vendor.save
      expect(@vendor.account.id).not_to be_nil
    end
  end

  context 'payout!' do
    before do
      @vendor = create(:vendor)
      @payment_method_ach = create(:payment_method_ach, resource: @vendor, is_default: false)
      @payment_method_invoice = create(:payment_method_invoice, resource: @vendor, is_default: false)
      @vendor.account.credit!(Money.new(345_000), status: 'posted')
    end

    it 'should create a payment for the account balance' do
      expect { @vendor.payout!('', payment_method: @payment_method_ach, balance_amount: '3450') }.to change { @vendor.payments.count }.by(1).and change { @vendor.account.transactions.debit.count }.by(1)

      @payment_method_ach.update(is_default: true)
      expect { @vendor.payout! }.to raise_error('amount cannot be less than or equal to zero')

      @vendor.account.credit!(Money.new(45_000), status: 'posted')
      expect { @vendor.payout! }.to change { @vendor.payments.count }.by(1).and change { @vendor.account.transactions.debit.count }.by(1)
    end

    it 'should raise an error for greater charge than balance' do
      expect { @vendor.payout!('', payment_method: @payment_method_ach, balance_amount: '34500') }.to raise_error('this action will make account balance negative')
    end

    it 'should should check for amount to be positive' do
      expect { @vendor.payout!('', payment_method: @payment_method_ach, balance_amount: '-34500') }.to raise_error('amount cannot be less than or equal to zero')
    end

    it 'should should check for external_id in case of invoice payment method' do
      expect { @vendor.payout!('', payment_method: @payment_method_invoice, balance_amount: '3450') }.to raise_error('valid external_id is required in case of payment_method invoice')
    end

    it 'should should raise an error for no payment method' do
      expect { @vendor.payout! }.to raise_error('no payment_method found on vendor account')
    end
  end
end
