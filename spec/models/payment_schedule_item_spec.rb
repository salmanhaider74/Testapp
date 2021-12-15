# == Schema Information
#
# Table name: payment_schedule_items
#
#  id                  :bigint           not null, primary key
#  payment_schedule_id :bigint
#  principal_cents     :integer          default(0), not null
#  principal_currency  :string           default("USD"), not null
#  interest_cents      :integer          default(0), not null
#  interest_currency   :string           default("USD"), not null
#  due_date            :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fees_cents          :integer          default(0), not null
#  fees_currency       :string           default("USD"), not null
#
require 'rails_helper'

RSpec.describe PaymentScheduleItem, type: :model do
  context 'payment schedule items creation' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer)
      @account = create(:customer_account, order: @order)
      @payment_schedule = create(:payment_schedule, account: @account)
      @payment_schedule_item = create(:payment_schedule_item, payment_schedule: @payment_schedule)
    end

    it 'should be valid object' do
      expect(@payment_schedule_item).to be_valid
    end

    it 'should have correct status' do
      @payment_schedule_item.update!(due_date: Date.tomorrow)
      expect(@payment_schedule_item.status).to eq('Upcoming')

      @payment_schedule_item.update!(due_date: Date.today)
      expect(@payment_schedule_item.status).to eq('Due')

      @payment_schedule_item.update!(due_date: Date.yesterday)
      expect(@payment_schedule_item.status).to eq('Late')

      @invoice = create(:invoice, amount: 4_000, customer: @customer, status: 'paid')
      @payment_schedule_item.update!(invoice: @invoice)
      expect(@payment_schedule_item.status).to eq('Paid')
    end
  end
end
