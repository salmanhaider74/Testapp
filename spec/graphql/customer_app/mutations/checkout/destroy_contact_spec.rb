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
              destroyOwner(
                  id: $id
              ) {
                  id
              }
            }
          GQL
        end

        it 'destroys contact and sets deleted_at to the current time' do
          mutation :customer, @mutation,
                   variables: {
                     id: @contact2.id,
                   },
                   context: @ucx
          expect(@contact2.reload.deleted_at).to_not eq(nil)
        end
      end
    end
  end
end
