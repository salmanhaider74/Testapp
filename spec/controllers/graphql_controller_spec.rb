require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  context 'execute' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @user = create(:user, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true)
      @order = create(:order, customer: @customer)
      @csession = create(:session, resource: @contact, order: @order)
      @usession = create(:session, resource: @user)
      @gql = <<~GQL
        {
          session {
            id
            user {
              id
              vendor {
                id
              }
            }
            contact {
              id
              customer {
                id
              }
            }
            order {
              id
            }
          }
        }
      GQL
    end

    it 'should return session for user' do
      cookies.signed[:jwt] = JsonWebToken.encode({ tkn: @usession.token })
      expect(CustomerAppSchema).not_to receive(:execute)
      post :execute, params: { query: @gql }
      data = JSON.parse(response.body)['data']
      expect(data['session']['id'].to_i).to eq(@usession.id)
      expect(data['session']['user']['id'].to_i).to eq(@user.id)
      expect(data['session']['user']['vendor']['id'].to_i).to eq(@vendor.id)
      expect(data['session']['contact']).to be_nil
      expect(data['session']['order']).to be_nil
    end

    it 'should return session for contact' do
      cookies.signed[:jwt] = JsonWebToken.encode({ tkn: @csession.token })
      expect(VendorAppSchema).not_to receive(:execute)
      post :execute, params: { query: @gql }
      data = JSON.parse(response.body)['data']
      expect(data['session']['id'].to_i).to eq(@csession.id)
      expect(data['session']['contact']['id'].to_i).to eq(@contact.id)
      expect(data['session']['contact']['customer']['id'].to_i).to eq(@customer.id)
      expect(data['session']['order']['id'].to_i).to eq(@order.id)
      expect(data['session']['user']).to be_nil
    end

    it 'should return invalid session' do
      post :execute, params: { query: @gql }
      data = JSON.parse(response.body)['data']
      expect(data['session']).to be_nil
    end
  end
end
