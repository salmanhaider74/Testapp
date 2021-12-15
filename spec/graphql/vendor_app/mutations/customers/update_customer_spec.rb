require 'rails_helper'

module VendorApp::Mutations
  module Customers
    RSpec.describe UpdateCustomer, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @usession = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer)
          @ucx = {
            current_session: @usession,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($id: ID!, $name: String, $ein: String) {
              updateCustomer(
                id: $id
                name: $name
                ein: $ein
              ) {
                id
              }
            }
          GQL
        end

        it 'updates customer with valid user session and attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: @customer.id,
                     name: 'ABC',
                     ein: '456-123-123',
                   },
                   context: @ucx
          expect(@customer.reload.name).to eq('ABC')
          expect(@customer.ein).to eq('*******-123')
        end

        it 'does not update customer with invalid session or attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: -1,
                     name: 'ABC',
                     ein: '456-123-123',
                   },
                   context: @ucx
          expect(@customer.reload.name).not_to eq('ABC')
          expect(@customer.ein).not_to eq('456-123-123')

          mutation :vendor, @mutation,
                   variables: {
                     id: @customer.id,
                     name: 'ABC',
                     ein: '456-123-123',
                   },
                   context: {}
          expect(@customer.reload.name).not_to eq('ABC')
        end
      end
    end
  end
end
