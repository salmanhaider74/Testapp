# == Schema Information
#
# Table name: dwolla_accounts
#
#  id             :bigint           not null, primary key
#  resource_type  :string           not null
#  resource_id    :bigint           not null
#  is_master      :string
#  url            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  verified       :boolean          default(FALSE), not null
#  funding_source :string
#
require 'rails_helper'

RSpec.describe DwollaAccount, type: :model do
  context 'create_account!' do
    before do
      @vendor = create(:vendor)
      @user = create(:user, vendor: @vendor)
      @payment_method = create(:payment_method_ach, is_default: false, resource: @vendor)
    end

    it 'It should check vendor has dwolla account' do
      @vendor.reload
      expect(@vendor.dwolla_account.present?).to eq(true)
    end

    it 'it should check payment method has funding source' do
      @payment_method.reload
      expect(@payment_method.funding_source.present?).to eq(false)
    end
  end
end
