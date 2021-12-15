require 'rails_helper'

RSpec.describe ChargeInvoicesJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform_later' do
    it 'enqueued the job' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        ChargeInvoicesJob.perform_later('low')
      end.to have_enqueued_job
    end
  end
end
