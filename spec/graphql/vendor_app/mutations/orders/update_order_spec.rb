require 'rails_helper'

module VendorApp::Mutations
  module Orders
    RSpec.describe UpdateOrder, type: :graphql do
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
            mutation($id: ID!, $interestRateSubsidy: Float) {
              updateOrder(
                id: $id
                interestRateSubsidy: $interestRateSubsidy
              ) {
                id
              }
            }
          GQL
        end

        it 'updates order with valid session and attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: @order.id,
                     interestRateSubsidy: 0.7,
                   },
                   context: @context
          expect(@order.reload.interest_rate_subsidy).to eq(0.7)
        end

        it 'does not update order with invalid session or attributes' do
          mutation :vendor, @mutation,
                   variables: {
                     id: -1,
                     status: 'approved',
                   },
                   context: @context
          expect(@order.reload.status).not_to eq('approved')

          mutation :vendor, @mutation,
                   variables: {
                     id: @order.id,
                     status: 'something',
                   },
                   context: @context
          expect(@order.reload.status).not_to eq('something')

          mutation :vendor, @mutation,
                   variables: {
                     id: @order.id,
                     status: 'approved',
                   },
                   context: {}
          expect(@order.reload.status).not_to eq('approved')

          @order.update(status: 'approved')
          mutation :vendor, @mutation,
                   variables: {
                     id: @order.id,
                     start_date: '2019-01-01',
                   },
                   context: @context
          expect(@order.reload.start_date.to_s).not_to eq('2019-01-01')
        end
      end
    end
  end
end
