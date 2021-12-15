require 'rails_helper'

module VendorApp::Mutations
  module Vendors
    RSpec.describe UpdateVendor, type: :graphql do
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
            mutation($name: String!) {
              updateVendor(
                name: $name
              ) {
                id
              }
            }
          GQL
        end

        it 'updates vendor with valid session and attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     name: 'Test',
                   },
                   context: @context
          expect(@vendor.reload.name).to eq('Test')
        end

        it 'does not update vendor with invalid session or attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     name: '',
                   },
                   context: @context
          expect(@vendor.reload.name).not_to eq('')

          mutation :vendor, @mutation,
                   variables: {
                     name: 'Test',
                   },
                   context: {}
          expect(@vendor.reload.name).not_to eq('Test')
        end
      end
    end
  end
end
