require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe UploadFinancialDocuments, type: :graphql do
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
            mutation($taxReturns: [Upload!]!, $bankStatements: [Upload!]!) {
              uploadFinancialDocuments(
                taxReturns: $taxReturns
                bankStatements: $bankStatements
              ) {
                id
              }
            }
          GQL
        end

        it 'upload financial statement with valid session' do
          @order.update(status: :application)
          @order.underwrite!(@contact)
          mutation :customer, @mutation,
                   variables: {
                     taxReturns: [fixture_file_upload('spec/fixtures/test.pdf', 'appliation/pdf')],
                     bankStatements: [fixture_file_upload('spec/fixtures/test.pdf', 'appliation/pdf')],
                   },
                   context: @context
          expect(@order.documents.count).to eq(2)
          expect(@order.documents.first.document).to be_attached
          expect(@order.reload.workflow_steps['steps']).to eq([
            { 'name' => 'personal_details', 'status' => 'complete' },
            { 'name' => 'business_details', 'status' => 'complete' },
            { 'name' => 'financial_documents', 'status' => 'complete' }
          ])
        end

        it 'does not upload financial statement with invalid session' do
          mutation :customer, @mutation,
                   variables: {
                     document: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')),
                   },
                   context: {}
          expect(@order.documents.count).to eq(0)
        end
      end
    end
  end
end
