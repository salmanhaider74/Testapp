# == Schema Information
#
# Table name: payments
#
#  id                :bigint           not null, primary key
#  resource_type     :string           not null
#  resource_id       :bigint           not null
#  external_id       :string
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  status            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  number            :string
#  error_message     :string
#  payment_method_id :bigint           not null
#
require 'rails_helper'

RSpec.describe Payment, type: :model do
  context 'CustomerPayment' do
    before do
      @customer_payment = create(:customer_payment)
    end

    it 'should have acceptable values' do
      expect(@customer_payment).to be_valid
    end
  end

  context 'VendorPayment' do
    before do
      @vendor_payment = create(:vendor_payment)
    end

    it 'should have acceptable values' do
      expect(@vendor_payment).to be_valid
    end
  end
end
