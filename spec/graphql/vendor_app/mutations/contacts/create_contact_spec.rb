require 'rails_helper'

module VendorApp::Mutations
  module Contacts
    RSpec.describe CreateContact, type: :graphql do
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
            mutation($customerId: ID!, $firstName: String!, $lastName: String!, $email: String!) {
              createContact(
                customerId: $customerId
                firstName: $firstName
                lastName: $lastName
                email: $email
              ) {
                id
                firstName
              }
            }
          GQL
        end

        it 'creates contact with valid user session' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       customerId: @customer.id,
                       email: 'test@test.com',
                       first_name: 'Test',
                       last_name: 'Test',
                     },
                     context: @ucx
          end.to change { @customer.contacts.count }.by(1)
        end

        it 'does not create contact with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       email: 'test@test.com',
                       first_name: 'Test',
                       last_name: 'Test',
                     },
                     context: @ucx
          end.to change { @customer.contacts.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       customerId: @customer.id,
                       email: 'test@test.com',
                       first_name: 'Test',
                       last_name: 'Test',
                     },
                     context: {}
          end.to change { @customer.contacts.count }.by(0)
        end
      end
    end
  end
end
