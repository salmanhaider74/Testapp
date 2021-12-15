require 'rails_helper'

module VendorApp::Mutations
  module Contacts
    RSpec.describe UpdateContact, type: :graphql do
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
            mutation($id: ID!, $firstName: String, $lastName: String) {
              updateContact(
                id: $id
                firstName: $firstName
                lastName: $lastName
              ) {
                id
              }
            }
          GQL
        end

        it 'updates contact with valid user session and attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: @contact.id,
                     firstName: 'ABC',
                   },
                   context: @ucx
          expect(@contact.reload.first_name).to eq('ABC')
        end

        it 'does not update contact with invalid session or attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: @contact.id,
                     firstName: '',
                   },
                   context: @ucx
          expect(@contact.reload.first_name).not_to eq('')

          mutation :vendor, @mutation,
                   variables: {
                     id: @contact.id,
                     firstName: 'ABC',
                   },
                   context: {}
          expect(@contact.reload.first_name).not_to eq('ABC')
        end
      end
    end
  end
end
