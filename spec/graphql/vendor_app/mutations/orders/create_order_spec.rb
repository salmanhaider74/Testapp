require 'rails_helper'

module VendorApp::Mutations
  module Orders
    RSpec.describe CreateOrder, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @context = {
            current_session: @session,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($customerId: ID!, $amount: Float!, $interestRateSubsidy: Float!, $endDate: ISO8601Date!, $startDate: ISO8601Date!) {
              createOrder(
                customerId: $customerId
                amount: $amount
                interestRateSubsidy: $interestRateSubsidy
                endDate: $endDate
                startDate: $startDate
              ) {
                id
              }
            }
          GQL
        end

        it 'creates order with valid session' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       customerId: @customer.id,
                       amount: 400,
                       interestRateSubsidy: 0.055,
                       endDate: '2102-12-31',
                       startDate: '2100-01-01',
                     },
                     context: @context
          end.to change { @customer.orders.count }.by(1)
        end

        it 'does not create order with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       amount: 400,
                       interestRateSubsidy: 0.055,
                       endDate: '2022-12-31',
                       startDate: '2020-01-01',
                     },
                     context: @context
          end.to change { @customer.orders.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       customerId: @customer.id,
                       amount: 400,
                       interestRateSubsidy: 0.055,
                       endDate: '2022-01-01',
                       startDate: '2020-01-01',
                     },
                     context: {}
          end.to change { @customer.orders.count }.by(0)
        end
      end

      context 'Create order with new customer' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @context = {
            current_session: @session,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($name: String!, $entityType: String!, $street: String!, $zip: String!, $city: String!, $state: String!, $country: String!, $firstName: String!, $lastName: String!, $email: String!, $phone: String!, $amount: Float!, $interestRateSubsidy: Float!, $endDate: ISO8601Date!, $startDate: ISO8601Date!) {
              createOrder(
                name: $name
                entityType: $entityType
                street: $street
                city: $city
                state: $state
                zip: $zip
                country: $country
                firstName: $firstName
                lastName: $lastName
                email: $email
                phone: $phone
                amount: $amount
                interestRateSubsidy: $interestRateSubsidy
                endDate: $endDate
                startDate: $startDate
              ) {
                id
              }
            }
          GQL
        end

        it 'creates order and customer with valid session' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       name: 'abd Customer',
                       entityType: 's_corp',
                       firstName: 'ABC',
                       lastName: 'ABC',
                       email: 'abd@gmail.com',
                       phone: '+13177587405',
                       street: '650 Lombard Street',
                       city: 'San Francisco',
                       state: 'CA',
                       zip: '94538',
                       country: 'US',
                       amount: 400,
                       interestRateSubsidy: 0.055,
                       endDate: '2023-03-16',
                       startDate: '2021-03-16',
                     },
                     context: @context
          end.to change { @vendor.customers.count }.by(1)
                                                   .and change { @vendor.orders.count }.by(1)
                                                                                       .and change { Contact.count }.by(1)
        end

        it 'does not create order with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       amount: 400,
                       interestRateSubsidy: 0.055,
                       endDate: '2022-12-31',
                       startDate: '2020-01-01',
                     },
                     context: @context
          end.to change { @vendor.customers.count }.by(0).and change { @vendor.orders.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       firstName: 'ABC',
                       lastName: 'ABC',
                       email: 'abd@gmail.com',
                       phone: '+13177587405',
                       street: '650 Lombard Street',
                       city: 'San Francisco',
                       state: 'CA',
                       zip: '94538',
                       country: 'US',
                       amount: 400,
                       interestRateSubsidy: 0.06,
                       endDate: '2022-12-31',
                       startDate: '2020-01-01',
                     },
                     context: @context
          end.to change { @vendor.customers.count }.by(0).and change { @vendor.orders.count }.by(0)
        end
      end
    end
  end
end
