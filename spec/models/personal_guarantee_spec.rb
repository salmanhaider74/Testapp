# == Schema Information
#
# Table name: personal_guarantees
#
#  id          :bigint           not null, primary key
#  order_id    :bigint           not null
#  contact_id  :bigint           not null
#  accepted_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe PersonalGuarantee, type: :model do
  context 'helpers and callbacks' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer)
      @personal_guarantee = create(:personal_guarantee, customer: @customer, order: @order)
    end

    it 'should return frozen? true if accepted_at is present' do
      expect(@personal_guarantee.frozen?).to be false

      @personal_guarantee.update!(accepted_at: Time.now)
      expect(@personal_guarantee.frozen?).to be true
    end
  end
end
