# == Schema Information
#
# Table name: payment_methods
#
#  id                       :bigint           not null, primary key
#  resource_type            :string           not null
#  resource_id              :bigint           not null
#  is_default               :boolean          default(TRUE)
#  payment_mode             :string
#  account_name             :string
#  account_type             :string
#  routing_number           :string
#  encrypted_account_number :string
#  contact_name             :string
#  phone                    :string
#  email                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bank                     :string
#  funding_source           :string
#  verified                 :boolean          default(FALSE), not null
#
require 'rails_helper'

RSpec.describe PaymentMethod, type: :model do
  context 'ach mode' do
    before do
      @vendor1 = create(:vendor)
      @user1 = create(:user, vendor: @vendor1)
      @vendor2 = create(:vendor)
      @user2 = create(:user, vendor: @vendor2)
      @payment_method1 = create(:payment_method_ach, is_default: false, resource: @vendor1)
      @payment_method2 = create(:payment_method_ach, is_default: false, resource: @vendor2)
    end

    it 'should conditionally validate ach fields' do
      expect(@payment_method1).to be_valid
      @payment_method1.account_name = ''
      expect(@payment_method1).to_not be_valid
    end

    it 'should not have more than one default payment methods' do
      expect(@payment_method1).to be_valid
      expect(@payment_method2).to be_valid
      @payment_method1.is_default = true
      @payment_method1.save
      expect(@payment_method1.is_default).to eq(true)
      @payment_method2.is_default = true
      @payment_method2.save
      expect(@payment_method1.reload.is_default).to eq(true)
      expect(@payment_method2.reload.is_default).to eq(true)
    end

    it 'account number should not change if masked value is set on it' do
      encrypted_account_number = @payment_method1.encrypted_account_number
      @payment_method1.account_number = '*******1234'
      expect(@payment_method1.encrypted_account_number).to eq(encrypted_account_number)
    end
  end

  context 'invoice mode' do
    before do
      @payment_method = create(:payment_method_invoice)
    end

    it 'should conditionally validate invoice fields' do
      expect(@payment_method).to be_valid
      @payment_method.contact_name = ''
      expect(@payment_method).to_not be_valid
    end
  end

  context 'plaid mode' do
    before do
      @payment_method = create(:payment_method_plaid)
    end

    it 'should contain plaid tokens' do
      expect(@payment_method).to be_valid
    end
  end

  context 'Create dwolla for vendor' do
    before do
      @vendor = create(:vendor)
      @user = create(:user, vendor: @vendor)
      @payment_method = create(:payment_method_ach, is_default: false, resource: @vendor)
    end

    it 'should contain funding source url' do
      expect(@payment_method).to be_valid
      @payment_method.reload
      expect(@payment_method.funding_source.present?).to eq(false)
    end
  end
end
