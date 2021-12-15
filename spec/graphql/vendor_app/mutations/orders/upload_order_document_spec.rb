require 'rails_helper'

module VendorApp::Mutations
  module Orders
    RSpec.describe UploadOrderDocument, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @order = create(:order, customer: @customer)
          @context = {
            current_session: @session,
            current_user: @user,
            current_vendor: @vendor,
          }
          @mutation = <<~GQL
            mutation($orderId: ID!, $documentType: String!, $document: Upload!) {
              uploadOrderDocument(orderId: $orderId, documentType: $documentType, document: $document) {
                id
              }
            }
          GQL
        end

        it 'uploads order form with valid session' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       document: fixture_file_upload('spec/fixtures/test.pdf', 'appliation/pdf'),
                       orderId: @order.id,
                       document_type: 'order_form',
                     },
                     context: @context
          end.to change { @order.documents.count }.by(1)
          expect(@order.reload.has_form).to eq(true)
        end

        it 'does not create order with invalid session or attributes' do
          expect do
            mutation :vendor, @mutation,
                     variables: {
                       amount: 400,
                     },
                     context: @context
          end.to change { @order.documents.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       customerId: @customer.id,
                     },
                     context: @context
          end.to change { @order.documents.count }.by(0)

          expect do
            mutation :vendor, @mutation,
                     variables: {
                       document: fixture_file_upload('spec/fixtures/test.pdf', 'appliation/pdf'),
                     },
                     context: {}
          end.to change { @order.documents.count }.by(0)
        end
      end
    end
  end
end
