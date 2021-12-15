require 'rails_helper'
require 'webmock/rspec'

RSpec.describe CallbackController, type: :controller do
  context 'create' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer, amount: 600_000)
      stub_request(:get, 'https://test.com').to_return(body: File.open(File.expand_path('./spec/fixtures/test.pdf')), status: 200)
      allow(Signature).to receive(:get_signed_agreement).and_return({ file_url: 'https://test.com' }.stringify_keys)
      allow(Order).to receive(:where).and_return([@order])
    end

    it 'should set acknowledge event from hello sign' do
      req_bdy = ActiveSupport::JSON.encode({
        account_guid: '63522885f9261e2b04eea043933ee7313eb674fd',
        event: {
          event_time: '1348177752',
          event_type: 'signature_request_all_signed',
          event_hash: '7c1a030348336ee0cf2c6f8de2b1cac76abff24a0a283437bfefade3b8f2c16e',
          file_url: 'http://test.com',
        },
        signature_request: {
          signature_request_id: '63522885f9261e2b04eea043933ee7313eb674fd',
        },
      })
      expect { post :create, params: { json: req_bdy }, as: :json }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(2)
      expect(response.status).to eq(200)
    end

    it 'should return 403 for invalid event' do
      req_bdy = ActiveSupport::JSON.encode({
        account_guid: '63522885f9261e2b04eea043933ee7313eb674fd',
        event: {
          event_time: '1348177752',
          event_type: 'signature_request_all_signed',
          event_hash: '3a31324d1919d7cdc849ff407adf38fc01e01107d9400b028ff8c892469ca947',
        },
        signature_request: {
          signature_request_id: '63522885f9261e2b04eea043933ee7313eb674fd',
        },
      })

      post :create, params: { json: req_bdy }, as: :json
      expect(response.status).to eq(403)
    end
  end
end
