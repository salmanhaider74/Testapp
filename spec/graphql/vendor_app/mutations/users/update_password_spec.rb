require 'rails_helper'

module VendorApp::Mutations
  module Users
    RSpec.describe UpdatePassword, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @user.send_reset_password_instructions
          @mutation = <<~GQL
            mutation($token: String!, $password: String!, $passwordConfirmation: String!) {
              updatePassword (
                token: $token
                password: $password
                passwordConfirmation: $passwordConfirmation
              ) {
                success
              }
            }
          GQL
        end

        it 'update password for valid token and password' do
          mutation :vendor, @mutation, variables: { token: @user.reset_password_token, password: '456123', passwordConfirmation: '456123' }
          expect(@user.reload.valid_password?('456123')).to eq(true)
        end

        it 'does not update password for invalid token or password' do
          mutation :vendor, @mutation, variables: { token: 'abcd', password: '456123', passwordConfirmation: '456123' }
          expect(@user.reload.valid_password?('456123')).to eq(false)

          mutation :vendor, @mutation, variables: { token: @user.reset_password_token, password: '456123', passwordConfirmation: '456144' }
          expect(@user.reload.valid_password?('456123')).to eq(false)
        end
      end
    end
  end
end
