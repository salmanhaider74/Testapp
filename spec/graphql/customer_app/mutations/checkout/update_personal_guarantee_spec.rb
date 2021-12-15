require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe UpdatePersonalGuarantee, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @product = create(:product, vendor: @vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer)
          @order = create(:order, customer: @customer, amount: 600_000)
          @personal_guarantee = create(:personal_guarantee, contact: @contact, order: @order)
          @context = {
            current_session: @session,
            current_user: @user,
            current_order: @order,
            current_contact: @contact,
          }
          @mutation = <<~GQL
            mutation ($agreed: Boolean!, $ssn: String!, $dob: ISO8601Date!) {
              updatePersonalGuarantee (
                agreed: $agreed
                ssn: $ssn
                dob: $dob
              ) {
                id
              }
            }
          GQL
        end

        it 'creates personal guarantee with valid session' do
          @order.update(status: :application)
          mutation :customer, @mutation,
                   variables: {
                     agreed: true,
                     ssn: '123-12-1234',
                     dob: '2021-10-10',
                   },
                   context: @context
          expect(@order.personal_guarantees.first.reload.accepted_at.present?).to eq(true)
          expect(@order.reload.workflow_steps['steps']).to eq([
            { 'name' => 'personal_details', 'status' => 'complete' },
            { 'name' => 'business_details', 'status' => 'complete' },
            { 'name' => 'financial_documents', 'status' => 'pending' }
          ])
        end

        it 'does not create personal guarantee with invalid session' do
          mutation :customer, @mutation,
                   context: {}
          expect(@order.personal_guarantees.first.reload.accepted_at.present?).to eq(false)
        end

        it 'does not create a non-agreed personal guarantee' do
          mutation :customer, @mutation,
                   variables: {
                     agreed: false,
                   },
                   context: @context
          expect(@order.personal_guarantees.first.reload.accepted_at.present?).to eq(false)
        end
      end
    end
  end
end
