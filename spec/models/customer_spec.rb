# == Schema Information
#
# Table name: customers
#
#  id             :bigint           not null, primary key
#  vendor_id      :bigint
#  name           :string
#  duns_number    :string
#  encrypted_ein  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entity_type    :string
#  date_started   :date
#  number         :string
#  bill_cycle_day :integer
#  verified_at    :datetime
#
require 'rails_helper'

RSpec.describe Customer, type: :model do
  context 'validations' do
    before do
      @vendor = create(:vendor)
      @customer = build(:customer, vendor: @vendor)
    end

    it 'should validate EIN' do
      # TODO: add test case
    end

    it 'should validate DUNS number' do
      # TODO: add test case
    end
  end

  context 'helper methods' do
    before do
      @vendor = create(:vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact1 = create(:contact, customer: @customer)
      @contact2 = create(:contact, customer: @customer)
    end

    it 'should return primary contact' do
      expect(@customer.primary_contact.id).to eq(@contact1.id)

      @contact2.make_primary!
      expect(@customer.primary_contact.id).to eq(@contact2.id)
    end
  end

  context 'generate invoice' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @contact.customer)
      @order.finance!
    end

    it 'it should check new invoice is generated' do
      expect(@customer.create_invoice!).to be true
      expect(@order.account.payment_schedule.payment_schedule_items.map(&:invoice).compact.count).to eq(1)
      expect(@order.account.payment_schedule.payment_schedule_items.first.payment).to eq(@customer.invoices.first.amount)
    end
  end

  context 'generate invoice with two orders' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @contact.customer)
      @second_order = create(:order, customer: @contact.customer)

      @order.finance!
      @second_order.finance!
    end

    it 'it should check new invoice has amount equal to sum of customers payment_schedule_items' do
      expect(@customer.create_invoice!).to be true
      expect(@order.account.payment_schedule.payment_schedule_items.first.payment + @second_order.account.payment_schedule.payment_schedule_items.first.payment).to eq(@customer.invoices.first.amount)
    end
  end
end
