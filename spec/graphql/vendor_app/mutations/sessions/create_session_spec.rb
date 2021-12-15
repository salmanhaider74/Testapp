require 'rails_helper'

module VendorApp::Mutations
  module Sessions
    RSpec.describe CreateSession, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @mutation = <<~GQL
            mutation($email: String!, $password: String!) {
              signIn(
                email: $email
                password: $password
              ) {
                id
                token
                user {
                  id
                }
              }
            }
          GQL
        end

        it 'signs in with valid credentials' do
          expect do
            mutation :vendor, @mutation, variables: { email: @user.email, password: '123456' }
          end.to change { Session.count }.by(1)
        end

        it 'throws error with invalid credentials' do
          expect do
            mutation :vendor, @mutation, variables: { email: @user.email, password: '4563121' }
          end.to change { Session.count }.by(0)
        end
      end
    end
  end
end
