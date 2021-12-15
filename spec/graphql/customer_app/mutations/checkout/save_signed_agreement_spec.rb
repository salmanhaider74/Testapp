require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe SaveSignedAgreement, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer)
          @order = create(:order, customer: @customer)
          @personal_guarantee = create(:personal_guarantee, contact: @contact, order: @order)
          @context = {
            current_session: @session,
            current_user: @user,
            current_order: @order,
            current_contact: @contact,
            current_customer: @customer,
          }
          @mutation = <<~GQL
            mutation {
              saveSignedAgreement {
                id
              }
            }
          GQL
        end

        it 'should save agreement with valid context' do
          mutation :customer, @mutation, context: @context
          expect(@order.reload.status).to eq('agreement')
        end

        it 'should not save agreement with invalid session' do
          mutation :customer, @mutation, context: {}
          expect(@order.reload.status).to_not eq('agreement')
        end
      end
    end
  end
end
