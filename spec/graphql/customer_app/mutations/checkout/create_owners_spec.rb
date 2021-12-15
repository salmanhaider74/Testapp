require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe CreateOwners, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer, primary: true)
          @order = create(:order, customer: @customer, amount: 600_000)
          @csession = create(:session, resource: @contact)
          @ccx = {
            current_session: @csession,
            current_contact: @contact,
            current_customer: @customer,
            current_order: @order,
          }
          @mutation = <<~GQL
            mutation($owners: [OwnerInput!]!) {
              createOwners(
                owners: $owners
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
          @order.underwrite!(@contact)
          expect do
            mutation :customer, @mutation,
                     variables: {
                       owners: [
                         {
                           id: @contact.id,
                           first_name: 'ABC1',
                           last_name: 'ABC1',
                           ownership: 10.1,
                           email: 'test1@test.co',
                           phone: '+13177587405',
                           role: 'owner',
                         },
                         {
                           first_name: 'ABC2',
                           last_name: 'ABC2',
                           ownership: 12.1,
                           email: 'test2@test.co',
                           phone: '+13177587405',
                           role: 'owner',
                         }
                       ],
                     },
                     context: @ccx
          end.to change { @customer.contacts.count }.by(1)
          expect(@contact.reload.first_name).to eq('ABC1')
          expect(@order.reload.workflow_steps['steps']).to eq([
            { 'name' => 'personal_details', 'status' => 'complete' },
            { 'name' => 'business_details', 'status' => 'complete' },
            { 'name' => 'financial_documents', 'status' => 'pending' }
          ])
        end

        it 'does not update customer with invalid session or attributes' do
          expect do
            mutation :customer, @mutation,
                     variables: {
                       owners: [
                         {
                           id: @contact.id,
                           first_name: 'ABC1',
                           last_name: 'ABC1',
                           email: 'test1@test.co',
                           phone: '+13177587405',
                           role: 'owner',
                         },
                         {
                           first_name: 'ABC2',
                           last_name: 'ABC2',
                           email: 'test1@test.co',
                           phone: '+13177587405',
                           role: 'owner',
                         }
                       ],
                     },
                     context: @ccx
          end.to change { @customer.contacts.count }.by(0)
          expect(@contact.reload.first_name).not_to eq('ABC1')

          expect do
            mutation :customer, @mutation,
                     variables: {
                       owners: [
                         {
                           id: @contact.id,
                           first_name: 'ABC1',
                           last_name: 'ABC1',
                           email: 'test1@test.co',
                           phone: '+13177587405',
                           role: 'owner',
                         },
                         {
                           first_name: 'ABC2',
                           last_name: 'ABC2',
                           email: 'test2@test.co',
                           phone: '+13177587405',
                           role: 'owner',
                         }
                       ],
                     },
                     context: {}
          end.to change { @customer.contacts.count }.by(0)
          expect(@contact.reload.first_name).not_to eq('ABC1')
        end
      end
    end
  end
end
