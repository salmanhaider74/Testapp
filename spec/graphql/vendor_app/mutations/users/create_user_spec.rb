require 'rails_helper'

module VendorApp::Mutations
  module Users
    RSpec.describe CreateUser, type: :graphql do
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
            mutation($email: String!, $firstName: String!, $lastName: String!, $password: String!) {
              createUser(
                email: $email
                firstName: $firstName
                lastName: $lastName
                password: $password
              ) {
                id
              }
            }
          GQL
        end

        it 'creates user with valid session' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       email: 'test@test.com',
                       password: '123456',
                       first_name: 'Test',
                       last_name: 'Test',
                     },
                     context: @context
          end.to change { @vendor.users.count }.by(1)
        end

        it 'does not create user with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       email: 'test@test.com',
                       password: '123456',
                       first_name: '',
                       last_name: 'Test',
                     },
                     context: @context
          end.to change { @vendor.users.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       email: 'test@test.com',
                       password: '123456',
                       first_name: 'Test',
                       last_name: 'Test',
                     },
                     context: {}
          end.to change { @vendor.users.count }.by(0)
        end
      end
    end
  end
end
