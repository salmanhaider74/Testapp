require 'rails_helper'

RSpec.describe GenerateInvoicesJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform_later' do
    it 'enqueued the job' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        GenerateInvoicesJob.perform_later('low')
      end.to have_enqueued_job
    end
  end

  context 'invoice items validations' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer, interest_rate: 0.5, interest_rate_subsidy: 1, amount: 1440, billing_frequency: 'monthly', term: 36)
      @order.finance!
      @payment_schedule_item = @order.account.payment_schedule.payment_schedule_items.first
    end

    it 'should validate invoice amount by checking invoice items amount' do
      @payment_schedule_item.update(due_date: Date.today)
      GenerateInvoicesJob.perform_now
      invoice = @payment_schedule_item.order.customer.invoices.first
      expect(invoice.amount).to eq(@payment_schedule_item.principal + @payment_schedule_item.interest + @payment_schedule_item.fees)
      expect(invoice.invoice_items.sum(&:amount)).to eq(@payment_schedule_item.principal + @payment_schedule_item.interest + @payment_schedule_item.fees)
      expect(invoice.invoice_items.sum(&:amount)).to eq(invoice.amount)
      expect(invoice.due_date).to eq(@payment_schedule_item.due_date)
    end
  end
end
