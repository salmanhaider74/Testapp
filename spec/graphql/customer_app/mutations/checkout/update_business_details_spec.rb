require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe UpdateBusinessDetails, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer, primary: true, role: :officer)
          @customer_address = create(:address, resource: @contact, city: nil)
          @order = create(:order, customer: @customer, amount: 600_000)
          @csession = create(:session, resource: @contact)
          @ccx = {
            current_session: @csession,
            current_contact: @contact,
            current_customer: @customer,
            current_order: @order,
          }
          @mutation = <<~GQL
            mutation($name: String!, $ein: String!, $street: String!, $zip: String!, $city: String!, $state: String!, $country: String!, $dunsNumber: String!, $entityType: String!, $dateStarted: ISO8601Date!) {
              updateBusinessDetails(
                name: $name
                ein: $ein
                street: $street
                city: $city
                state: $state
                zip: $zip
                country: $country
                dunsNumber: $dunsNumber
                entityType: $entityType
                dateStarted: $dateStarted
              ) {
                id
                contact {
                  id
                }
                order {
                  id
                }
              }
            }
          GQL
        end

        it 'updates customer with valid session and attributes' do
          @order.update(status: :application)
          mutation :customer, @mutation,
                   variables: {
                     name: 'ABC',
                     ein: '46-123-123',
                     street: '650 Lombard Street',
                     city: 'San Francisco',
                     state: 'CA',
                     zip: '94538',
                     country: 'US',
                     dunsNumber: '612312350',
                     entityType: 'llc',
                     dateStarted: '2020-12-12',
                   },
                   context: @ccx
          expect(@customer.reload.name).to eq('ABC')
          expect(@customer.ein).to eq('******-123')
          expect(@order.reload.workflow_steps['steps']).to eq([
            { 'name' => 'personal_details', 'status' => 'complete' },
            { 'name' => 'business_details', 'status' => 'complete' },
            { 'name' => 'financial_documents', 'status' => 'pending' }
          ])
        end

        it 'does not update customer with invalid session or attributes' do
          mutation :customer, @mutation,
                   variables: {
                     name: 'ABC',
                     street: '650 Lombard Street',
                     city: 'San Francisco',
                     state: 'CA',
                     zip: '94538',
                     country: 'US',
                     dunsNumber: '612312350',
                     entityType: 'llc',
                     dateStarted: '2020-12-12',
                   },
                   context: @ccx
          expect(@customer.reload.name).not_to eq('ABC')
          expect(@customer.ein).not_to eq('456-123-123')

          mutation :customer, @mutation,
                   variables: {
                     name: 'ABC',
                     ein: '46-123-123',
                     street: '650 Lombard Street',
                     city: 'San Francisco',
                     state: 'CA',
                     zip: '94538',
                     country: 'US',
                     dunsNumber: '612312350',
                     entityType: 'llc',
                     dateStarted: '2020-12-12',
                   },
                   context: {}
          expect(@customer.reload.name).not_to eq('ABC')
        end
      end
    end
  end
end
