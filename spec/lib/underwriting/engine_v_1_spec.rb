require 'rails_helper'

module Underwriting::Engine
  RSpec.describe V1, type: :lib do
    context 'resolve' do
      before do
        @vendor = create(:vendor)
        @product = create(:product, vendor: @vendor)
        @customer = create(:customer, vendor: @vendor)
        @customer_address = create(:address, resource: @customer, city: nil)
        @contact = create(:contact, customer: @customer, primary: true, role: :officer)
        @contact_address = create(:address, resource: @contact, city: nil)
        @order = create(:order, customer: @customer, amount: 600_000)
        allow(Signature).to receive(:create_signature_request).and_return(:signature_request_id)
      end

      it 'updates order steps' do
        @order.update(status: :application)
        allow_any_instance_of(Contact).to receive(:inquiry_completed?).and_return(false)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'pending' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @customer_address.update(city: 'San Francisco')
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @contact_address.update(city: 'San Francisco')
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @contact.update(role: :owner)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @document_tax_return = create(:document, personal_guarantee: nil, order: @order, customer: @customer, type: :tax_return)
        @document_bank_statement = create(:document, personal_guarantee: nil, order: @order, customer: @customer, type: :bank_statement)
        @document_tax_return.document.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        @document_bank_statement.document.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' }
        ])

        @order.update(status: :checkout)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'pending' },
          { 'name' => 'verification', 'status' => 'pending' },
          { 'name' => 'agreement', 'status' => 'pending' }
        ])

        @pm = create(:payment_method_ach, resource: @customer, is_default: true)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'complete' },
          { 'name' => 'verification', 'status' => 'pending' },
          { 'name' => 'agreement', 'status' => 'pending' }
        ])

        allow_any_instance_of(Contact).to receive(:inquiry_completed?).and_return(true)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'complete' },
          { 'name' => 'verification', 'status' => 'complete' },
          { 'name' => 'agreement', 'status' => 'pending' }
        ])

        @order.update(status: :agreement)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'complete' },
          { 'name' => 'verification', 'status' => 'complete' },
          { 'name' => 'agreement', 'status' => 'complete' }
        ])

        @order.update(status: :financed)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'locked' },
          { 'name' => 'business_details', 'status' => 'locked' },
          { 'name' => 'financial_documents', 'status' => 'locked' },
          { 'name' => 'billing_information', 'status' => 'locked' },
          { 'name' => 'verification', 'status' => 'locked' },
          { 'name' => 'agreement', 'status' => 'locked' }
        ])
      end
    end

    context 'resolve for non owner' do
      before do
        @vendor = create(:vendor)
        @product = create(:product, vendor: @vendor)
        @customer = create(:customer, vendor: @vendor)
        @customer_address = create(:address, resource: @customer, city: nil)
        @contact = create(:contact, customer: @customer, primary: true, role: nil)
        @contact_address = create(:address, resource: @contact, city: nil)
        @order = create(:order, customer: @customer, amount: 600_000)
        allow(Signature).to receive(:create_signature_request).and_return(:signature_request_id)
      end

      it 'updates order steps' do
        @order.update(status: :application)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'pending' },
          { 'name' => 'business_details', 'status' => 'pending' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @contact.update(role: 'other')
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'pending' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @customer_address.update(city: 'San Francisco')
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'pending' }
        ])

        @document_tax_return = create(:document, personal_guarantee: nil, order: @order, customer: @customer, type: :tax_return)
        @document_bank_statement = create(:document, personal_guarantee: nil, order: @order, customer: @customer, type: :bank_statement)
        @document_tax_return.document.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        @document_bank_statement.document.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' }
        ])

        @order.update(status: :checkout)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'pending' },
          { 'name' => 'send_application', 'status' => 'pending' }
        ])

        @pm = create(:payment_method_ach, resource: @customer, is_default: true)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'complete' },
          { 'name' => 'send_application', 'status' => 'pending' }
        ])

        @order.update(application_sent: true)
        @order.underwrite!(@contact)
        expect(@order.reload.workflow_steps['steps']).to eq([
          { 'name' => 'personal_details', 'status' => 'complete' },
          { 'name' => 'business_details', 'status' => 'complete' },
          { 'name' => 'financial_documents', 'status' => 'complete' },
          { 'name' => 'billing_information', 'status' => 'complete' },
          { 'name' => 'send_application', 'status' => 'complete' }
        ])
      end
    end
  end
end
