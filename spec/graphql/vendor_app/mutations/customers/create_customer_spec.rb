require 'rails_helper'

module VendorApp::Mutations
  module Customers
    RSpec.describe CreateCustomer, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @context = {
            current_session: @session,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($name: String!, $street: String!, $city: String!, $state: String!, $zip: String!, $country: String!) {
              createCustomer(
                name: $name
                street: $street
                city: $city
                state: $state
                zip: $zip
                country: $country
              ) {
                id
              }
            }
          GQL
        end

        it 'creates customer with valid session' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       name: 'Test Vendor',
                       street: '630 7th Ave',
                       city: 'San Francisco',
                       state: 'CA',
                       zip: '94118',
                       country: 'US',
                     },
                     context: @context
          end.to change { @vendor.customers.count }.by(1)
        end

        it 'does not create customer with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       name: 'Test Vendor',
                       street: '630 7th Ave',
                       city: 'San Francisco',
                       zip: '94118',
                       country: 'US',
                     },
                     context: @context
          end.to change { @vendor.customers.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       name: 'Test Vendor',
                       street: '630 7th Ave',
                       city: 'San Francisco',
                       state: 'CA',
                       zip: '94118',
                       country: 'US',
                     },
                     context: {}
          end.to change { @vendor.customers.count }.by(0)
        end
      end
    end
  end
end
