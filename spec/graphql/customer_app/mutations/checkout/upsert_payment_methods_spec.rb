require 'rails_helper'

module CustomerApp::Mutations::Checkout
  RSpec.describe UpsertPaymentMethod, type: :graphql do
    context 'resolve' do
      before do
        allow_any_instance_of(Contact).to receive(:inquiry_completed?).and_return(true)
        @vendor = create(:vendor)
        @product = create(:product, vendor: @vendor)
        @customer = create(:customer, vendor: @vendor)
        @contact = create(:contact, customer: @customer, primary: true, role: :officer)
        @contact_address = create(:address, resource: @contact, city: nil)
        @usession = create(:contact_session, resource: @contact)
        @order = create(:order, customer: @customer, status: 'checkout')
        allow(Signature).to receive(:create_signature_request).and_return(:signature_request_id)
        @mutation = <<~GQL
          mutation(
              $id: ID,
              $paymentMode: String!,
              $bank: String,
              $accountName: String,
              $accountType: String,
              $routingNumber: String,
              $accountNumber: String,
              $contactName: String,
              $phone: String,
              $email: String,
              $street: String,
              $suite: String,
              $city: String,
              $state: String,
              $zip: String,
              $country: String
          ) {
            upsertPaymentMethod(
                id: $id
                bank: $bank
                paymentMode: $paymentMode
                accountName: $accountName
                accountType: $accountType
                routingNumber: $routingNumber
                accountNumber: $accountNumber
                contactName: $contactName
                phone: $phone
                email: $email
                street: $street
                suite: $suite
                city: $city
                state: $state
                zip: $zip
                country: $country
            ) {
                id
            }
          }
        GQL
      end

      context 'with customer' do
        before do
          @ucx = {
            current_contact: @contact,
            current_customer: @customer,
            current_session: @usession,
            current_vendor: @vendor,
            current_order: @order,
          }
        end

        it 'creates a valid payment information for the current customer' do
          mutation :customer, @mutation,
                   variables: {
                     paymentMode: 'ach',
                     bank: 'Bank of America',
                     accountName: 'Account name',
                     accountType: 'savings',
                     routingNumber: '222222226',
                     accountNumber: '123456789',
                   },
                   context: @ucx
          expect(@customer.reload.payment_methods.first).to_not eq(nil)
          expect(@order.reload.signature_request_id).to_not eq(nil)
        end

        it 'should not create a payment information for the current customer' do
          mutation :customer, @mutation,
                   variables: {
                     paymentMode: 'ach',
                     accountName: 'Account name',
                     accountType: 'savings',
                     routingNumber: '123456789',
                   },
                   context: @ucx
          expect(@customer.reload.payment_methods.first).to eq(nil)
          expect(@order.reload.signature_request_id).to eq(nil)
        end
      end
    end
  end
end
