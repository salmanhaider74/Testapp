# == Schema Information
#
# Table name: documents
#
#  id                    :bigint           not null, primary key
#  customer_id           :bigint           not null
#  order_id              :bigint
#  personal_guarantee_id :bigint
#  type                  :string
#  json_data             :jsonb            not null
#
require 'rails_helper'

RSpec.describe Document, type: :model do
  context 'validations and methods' do
    context 'type value' do
      before do
        @vendor = create(:vendor)
        @product = create(:product, vendor: @vendor)
        @customer = create(:customer, vendor: @vendor)
        @order = create(:order, customer: @customer)
        @personal_guarantee = create(:personal_guarantee, customer: @customer)
        @document = create(:document, customer: @customer, order: @order, personal_guarantee: @personal_guarantee)
      end

      it 'should be included in acceptable values' do
        expect(@document).to be_valid
        @document.type = 'abc'
        expect(@document).to_not be_valid
      end
    end

    context 'with a valid file' do
      before(:each) do
        @vendor = create(:vendor)
        @product = create(:product, vendor: @vendor)
        @customer = create(:customer, vendor: @vendor)
        @order = create(:order, customer: @customer)
        @personal_guarantee = create(:personal_guarantee, customer: @customer)
        @document = create(:document, customer: @customer, order: @order, personal_guarantee: @personal_guarantee)
      end

      it 'is attached' do
        @document.document.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        expect(@document.document).to be_attached
      end
    end
  end
end
