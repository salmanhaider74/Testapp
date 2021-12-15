# == Schema Information
#
# Table name: invoice_items
#
#  id                       :bigint           not null, primary key
#  invoice_id               :bigint           not null
#  payment_schedule_item_id :bigint           not null
#  transaction_id           :bigint
#  order_item_id            :bigint
#  name                     :string
#  description              :string
#  amount_cents             :integer          default(0), not null
#  amount_currency          :string           default("USD"), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  number                   :string
#  amount_charged_cents     :integer          default(0), not null
#  amount_charged_currency  :string           default("USD"), not null
#
require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  context 'validations' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer)
      @order_item = create(:order_item, order: @order)
      @invoice = create(:invoice)
      @invoice_item = build(:invoice_item, invoice: @invoice, order_item: @order_item)
    end

    it 'should validate the mandatory columns' do
      expect(@invoice_item.valid?).to be true

      @invoice_item.invoice_id = nil
      expect(@invoice_item.valid?).to be false

      @invoice_item.name = nil
      expect(@invoice_item.valid?).to be false

      @invoice_item.description = nil
      expect(@invoice_item.valid?).to be false

      @invoice_item.amount = nil
      expect(@invoice_item.valid?).to be false
    end

    it 'should have belongs_to assication with' do
      t = InvoiceItem.reflect_on_association(:payment_schedule_item)
      expect(t.macro).to eq(:belongs_to)

      t = InvoiceItem.reflect_on_association(:order_item)
      expect(t.macro).to eq(:belongs_to)

      t = InvoiceItem.reflect_on_association(:invoice)
      expect(t.macro).to eq(:belongs_to)
    end
  end
end
