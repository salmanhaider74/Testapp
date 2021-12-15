require 'rails_helper'

RSpec.describe PayoutVendorsJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform_later' do
    it 'enqueued the job' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        PayoutVendorsJob.perform_later('low')
      end.to have_enqueued_job
    end
  end

  context 'invoice items validations' do
    before do
      @vendor = create(:vendor)
      @payment_method_ach = create(:payment_method_ach, resource: @vendor, is_default: true)
    end

    it 'should create a payment for a vendor for the balance on account' do
      @vendor.account.credit!(Money.new(345_000), status: 'posted')
      PayoutVendorsJob.perform_now
      expect(@vendor.payments.count).to eq(1)
      expect(@vendor.payments.sum(&:amount)).to eq(Money.new(345_000))
      expect(@vendor.account.reload.transactions.debit.sum(&:principal)).to eq(Money.new(345_000))
    end
  end
end
