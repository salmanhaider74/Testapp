require 'rails_helper'

module VendorApp::Mutations
  module Sessions
    RSpec.describe DestroySession, type: :graphql do
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
            mutation {
              signOut {
                id
                token
                user {
                  id
                }
              }
            }
          GQL
        end

        it 'signs out with valid credentials' do
          expect do
            mutation :vendor, @mutation, variables: {}, context: @context
          end.to change { Session.count }.by(-1)
        end

        it 'throws error with invalid credentials' do
          expect do
            mutation :vendor, @mutation, variables: {}, context: {}
          end.to change { Session.count }.by(0)
        end
      end
    end
  end
end
