# == Schema Information
#
# Table name: payment_schedules
#
#  id                :bigint           not null, primary key
#  account_id        :bigint
#  version           :integer          default(1)
#  status            :string
#  term              :decimal(, )
#  start_date        :date
#  end_date          :date
#  billing_frequency :string
#  interest_rate     :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe PaymentSchedule, type: :model do
  context 'create_from_order!' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer)
      @account = create(:customer_account, order: @order)
      PaymentSchedule.create_from_order!(@account.order)
    end

    it 'should have valid payment schedule' do
      expect(@account.payment_schedule).to be_valid
    end
    it 'should have payment schedule items' do
      pmt_schdl = @account.payment_schedule
      expect(pmt_schdl.payment_schedule_items.count).to be_positive
    end
    it 'should have no payment schedule items with respect to billing_frequency' do
      pmt_schdl = @account.payment_schedule
      order = @account.order

      expect(pmt_schdl)
        .to have_attributes(term: order.term,
                            start_date: order.start_date,
                            end_date: order.end_date,
                            billing_frequency: order.billing_frequency,
                            interest_rate: order.customer_interest_rate)

      expect(pmt_schdl.payment_schedule_items.count)
        .to eq(order.num_pmts)
    end
  end
end
