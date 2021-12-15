require 'rails_helper'

module VendorApp::Mutations
  module Users
    RSpec.describe UpdateUser, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user1 = create(:user, vendor: @vendor, password: '123456')
          @user2 = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user1)
          @context = {
            current_session: @session,
            current_user: @user1,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($id: ID!, $firstName: String!, $lastName: String!) {
              updateUser(
                id: $id
                firstName: $firstName
                lastName: $lastName
              ) {
                id
              }
            }
          GQL
        end

        it 'updates user with valid session and attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: @user2.id,
                     first_name: 'Test',
                     last_name: 'Test',
                   },
                   context: @context
          expect(@user2.reload.first_name).to eq('Test')
        end

        it 'does not update user with invalid session or attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: -1,
                     first_name: 'Test',
                     last_name: 'Test',
                   },
                   context: @context
          expect(@user2.reload.first_name).not_to eq('Test')

          mutation :vendor, @mutation,
                   variables: {
                     id: @user2.id,
                     first_name: '',
                     last_name: 'Test',
                   },
                   context: @context
          expect(@user2.reload.first_name).not_to eq('')

          mutation :vendor, @mutation,
                   variables: {
                     id: @user2.id,
                     first_name: 'Test',
                     last_name: 'Test',
                   },
                   context: {}
          expect(@user2.reload.first_name).not_to eq('Test')
        end
      end
    end
  end
end
