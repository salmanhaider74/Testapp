require 'rails_helper'

module VendorApp::Mutations
  module Users
    RSpec.describe ResetPassword, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @mutation = <<~GQL
            mutation($email: String!) {
              resetPassword (
                email: $email
              ) {
                success
              }
            }
          GQL
        end

        it 'sends reset password instruction for invalid email' do
          expect do
            mutation :vendor, @mutation, variables: { email: @user.email }
          end.to change { ActionMailer::Base.deliveries.size }.by(1)
        end

        it 'does nothing for invalid email' do
          expect do
            mutation :vendor, @mutation, variables: { email: 'invalidemail@invalid.com' }
          end.to change { ActionMailer::Base.deliveries.size }.by(0)
        end
      end
    end
  end
end
