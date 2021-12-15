require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe UpdatePersonalDetails, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer, primary: true, role: :officer)
          @order = create(:order, customer: @customer, amount: 600_000)
          @csession = create(:session, resource: @contact)
          @ccx = {
            current_session: @csession,
            current_contact: @contact,
            current_customer: @customer,
            current_order: @order,
          }
          @mutation = <<~GQL
            mutation($firstName: String!, $lastName: String!, $email: String!, $phone: String!, $dob: ISO8601Date!, $role: String!) {
              updatePersonalDetails(
                firstName: $firstName
                lastName: $lastName
                email: $email
                phone: $phone
                dob: $dob
                role: $role
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
                     firstName: 'ABC',
                     lastName: 'ABC',
                     email: 'abd@gmail.com',
                     phone: '+13177587405',
                     dob: '2021-10-10',
                     role: 'officer',
                   },
                   context: @ccx
          expect(@contact.reload.first_name).to eq('ABC')
          expect(@order.reload.workflow_steps['steps']).to eq([
            { 'name' => 'personal_details', 'status' => 'complete' },
            { 'name' => 'business_details', 'status' => 'complete' },
            { 'name' => 'financial_documents', 'status' => 'pending' }
          ])
        end

        it 'does not update customer with invalid session or attributes' do
          mutation :customer, @mutation,
                   variables: {
                     lastName: 'ABC',
                     phone: '+13177587405',
                     dob: '2021-10-10',
                     role: 'owner',
                   },
                   context: @ccx
          expect(@contact.reload.first_name).not_to eq('ABC')

          mutation :customer, @mutation,
                   variables: {
                     firstName: 'ABC',
                     lastName: 'ABC',
                     phone: '+13177587405',
                     dob: '2021-10-10',
                     role: 'owner',
                   },
                   context: {}
          expect(@contact.reload.first_name).not_to eq('ABC')
        end
      end
    end
  end
end
