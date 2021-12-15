require 'rails_helper'

module VendorApp::Mutations
  module Orders
    RSpec.describe GrantFullcheckConsent, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @order = create(:order, customer: @customer, amount: 600_000)
          @context = {
            current_session: @session,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($orderId: ID!) {
              grantFullcheckConsent(
                orderId: $orderId
              ) {
                id
              }
            }
          GQL
        end

        it 'grants fullcheck consent from vendor' do
          expect(@order.fullcheck_consent).to eq(false)
          mutation :vendor, @mutation,
                   variables: {
                     orderId: @order.id,
                   },
                   context: @context
          expect(@order.reload.fullcheck_consent).to eq(true)
        end

        it 'does not grants fullcheck consent from vendor' do
          expect(@order.fullcheck_consent).to eq(false)
          mutation :vendor, @mutation,
                   variables: {
                     orderId: -1,
                   },
                   context: @context
          expect(@order.reload.fullcheck_consent).to eq(false)
        end
      end
    end
  end
end
