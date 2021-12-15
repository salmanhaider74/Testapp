require 'rails_helper'

module CustomerApp::Mutations
  module Checkout
    RSpec.describe UpdateContactVerificationStatus, type: :graphql do
      context 'resolve' do
        before do
          @vendor = create(:vendor)
          @user = create(:user, vendor: @vendor, password: '123456')
          @session = create(:session, resource: @user)
          @customer = create(:customer, vendor: @vendor)
          @contact = create(:contact, customer: @customer)
          @order = create(:order, customer: @customer, status: 'checkout')
          @context = {
            current_session: @session,
            current_user: @user,
            current_order: @order,
            current_contact: @contact,
            current_customer: @customer,
          }

          allow_any_instance_of(Contact).to receive(:inquiry_status).and_return('completed')

          @mutation = <<~GQL
            mutation {
              updateContactVerificationStatus {
                order {
                  id
                  workflowSteps
                }
              }
            }
          GQL
        end

        it 'checks if verification order step is complete' do
          mutation :customer, @mutation,
                   context: @context

          expect(@order.reload.workflow_steps['steps']).to eq([
            { 'name' => 'billing_information', 'status' => 'pending' },
            { 'name' => 'verification', 'status' => 'complete' },
            { 'name' => 'agreement', 'status' => 'pending' }
          ])

          expect(@contact.verified).to eq true
        end
      end
    end
  end
end
