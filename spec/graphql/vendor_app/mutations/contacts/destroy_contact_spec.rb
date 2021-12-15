require 'rails_helper'

module VendorApp::Mutations
  module Contacts
    RSpec.describe DestroyContact, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @usession = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer)
          @contact2 = create(:contact, customer: @customer)
          @ucx = {
            current_session: @usession,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($id: ID!) {
              destroyContact(
                id: $id
              ) {
                id
              }
            }
          GQL
        end

        it 'destroys contact with valid user session and attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       id: @contact.id,
                     },
                     context: @ucx
          end.to change { @customer.contacts.count }.by(-1)
        end

        it 'does not destroy contact with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       id: -1,
                     },
                     context: @ucx
          end.to change { @customer.contacts.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       id: @contact.id,
                     },
                     context: {}
          end.to change { @customer.contacts.count }.by(0)
        end
      end
    end
  end
end
