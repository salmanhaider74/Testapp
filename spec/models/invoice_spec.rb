# == Schema Information
#
# Table name: invoices
#
#  id              :bigint           not null, primary key
#  customer_id     :bigint
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  status          :string
#  posted_date     :date
#  due_date        :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  number          :string
#  invoice_date    :date
#
require 'rails_helper'

RSpec.describe Invoice, type: :model do
  context 'validations' do
    before do
      @invoice = build(:invoice)
    end

    it 'should validate posted and due date' do
      expect(@invoice.valid?).to be true

      @invoice.posted_date = Date.today + 10.days
      expect(@invoice.valid?).to be false

      @invoice.posted_date = Date.today
      @invoice.due_date = Date.today - 10.days
      expect(@invoice.valid?).to be false

      @invoice.posted_date = nil
      @invoice.due_date = nil
      expect(@invoice.valid?).to be true
    end
  end

  context 'invoice items validations' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @order = create(:order, customer: @customer, interest_rate: 0.12, interest_rate_subsidy: 0.12, amount: 1440)
      @first_order_item = create(:order_item, order: @order, quantity: 1, unit_price_cents: 2_000)
      @second_order_item = create(:order_item, order: @order, quantity: 1, unit_price_cents: 2_000)
      @order.finance!
      @payment_schedule_item = @order.account.payment_schedule.payment_schedule_items.first
      @invoice = create(:invoice, amount: 4_000)
    end

    it 'should validate invoice amount by checking invoice items amount' do
      expect(@invoice.valid?).to be true
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '1',
                                     description: '1 description',
                                     payment_schedule_item: @payment_schedule_item,
                                     order_item: @first_order_item)
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '2',
                                     description: '2 description',
                                     payment_schedule_item: @payment_schedule_item,
                                     order_item: @second_order_item)
      expect(@invoice.reload.valid?).to be true
    end

    it 'should validate invoice amount by checking invoice items amount' do
      expect(@invoice.valid?).to be true
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '1',
                                     description: '1 description',
                                     payment_schedule_item: @payment_schedule_item,
                                     order_item: @first_order_item)
      @invoice.invoice_items.create!(amount: 5_000,
                                     name: '2',
                                     description: '2 description',
                                     payment_schedule_item: @payment_schedule_item,
                                     order_item: @second_order_item)
      expect(@invoice.reload.valid?).to be false
    end
  end

  context 'email_invoice' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @contact.update(primary: true)
      create(:payment_method_ach, is_default: true, resource: @contact.customer)
      order = create(:order, customer: @customer, interest_rate: 0.12, interest_rate_subsidy: 0.12, amount: 1440, billing_frequency: 'monthly')
      first_order_item = create(:order_item, order: order, quantity: 1, unit_price_cents: 2_000)
      second_order_item = create(:order_item, order: order, quantity: 1, unit_price_cents: 2_000)
      order.finance!
      payment_schedule_item = order.account.payment_schedule.payment_schedule_items.first
      @invoice = @contact.customer.invoices.create(amount: 4_000, due_date: Date.current + 7.days)
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '1',
                                     description: '1 description',
                                     payment_schedule_item: payment_schedule_item,
                                     order_item: first_order_item)
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '2',
                                     description: '2 description',
                                     payment_schedule_item: payment_schedule_item,
                                     order_item: second_order_item)
    end

    it 'should send invoice email if not pending or paid' do
      expect(@invoice.email_invoice).to be true

      @invoice.update(status: :pending)
      expect(@invoice.email_invoice).to be true
    end
  end

  context 'charge!', type: :request do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer, primary: true, role: :officer)
      @contact_address = create(:address, resource: @contact, city: nil)
      @order = create(:order, interest_rate: 0.12, interest_rate_subsidy: 1, amount: 1440, billing_frequency: 'monthly', term: 3, customer: @customer)
      @first_order_item = create(:order_item, order: @order, quantity: 1, unit_price_cents: 2_000)
      @second_order_item = create(:order_item, order: @order, quantity: 1, unit_price_cents: 2_000)
      @order.finance!
      @payment_schedule_item = @order.account.payment_schedule.payment_schedule_items.first
      @invoice = create(:invoice, amount: 4_000, customer: @customer)
      @invoice.invoice_items.create!(amount: 2_000, name: '1', description: '1 description', payment_schedule_item: @payment_schedule_item, order_item: @first_order_item)
      @invoice.invoice_items.create!(amount: 2_000, name: '2', description: '2 description', payment_schedule_item: @payment_schedule_item, order_item: @second_order_item)

      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), Rails.application.credentials[:secret_key_base], { resourceId: '123456', topic: 'transfer_completed' }.to_json)
      @headers = { 'ACCEPT' => 'application/json', 'HTTP_X_REQUEST_SIGNATURE_SHA_256' => signature }
    end

    it 'should charge an invoice with payment method invoice' do
      create(:payment_method_invoice, resource: @customer, is_default: true)
      expect { @invoice.charge!('123456') }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @invoice.reload.status }.to('paid').and change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(400_000)
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 200_000])
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge an invoice with different payment method' do
      payment_method = create(:payment_method_invoice, resource: @customer, is_default: false)
      expect { @invoice.charge!('123456', payment_method: payment_method) }.to change { @invoice.invoice_payments.count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @invoice.reload.status }.to('paid').and change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(400_000)
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 200_000])
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
      expect(payment.payment_method_id).to eq(payment_method.id)
    end

    it 'should charge an invoice with less amount' do
      payment_method = create(:payment_method_invoice, resource: @customer, is_default: false)
      expect { @invoice.charge!('123456', payment_method: payment_method, invoice_amount: @invoice.amount / 2) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(200_000)
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 0])
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
      expect(payment.payment_method_id).to eq(payment_method.id)
    end

    it 'should charge an invoice with less amount' do
      payment_method = create(:payment_method_invoice, resource: @customer, is_default: false)
      expect { @invoice.charge!('123456', payment_method: payment_method, invoice_amount: Money.new(@invoice.amount_cents - 350_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to eq([50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([50_000, 0])
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(50_000)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
      expect(payment.payment_method_id).to eq(payment_method.id)
    end

    it 'should charge an invoice with less amount' do
      payment_method = create(:payment_method_invoice, resource: @customer, is_default: false)
      expect { @invoice.charge!('123456', payment_method: payment_method, invoice_amount: Money.new(@invoice.amount_cents - 100_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([100_000, 200_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 100_000])
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(300_000)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
      expect(payment.payment_method_id).to eq(payment_method.id)
    end

    it 'should charge an invoice with payment method ach and payment service success' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge! }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @invoice.reload.status }.to('paid').and change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(400_000)
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 200_000])
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge an invoice with payment method ach and custom payment_method' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      payment_method = create(:payment_method_ach, resource: @customer, is_default: false)
      expect { @invoice.charge!(payment_method: payment_method) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @invoice.reload.status }.to('paid').and change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(400_000)
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 200_000])
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge an invoice with payment method ach and less amount' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge!(invoice_amount: @invoice.amount / 2) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(200_000)
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 0])
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge an invoice with payment method ach and less amount and not credit all items' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge!(invoice_amount: Money.new(@invoice.amount_cents - 100_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([100_000, 200_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 100_000])
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(300_000)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge an invoice with payment method ach and less amount and not credit all items' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge!(invoice_amount: Money.new(@invoice.amount_cents - 350_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to eq([50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([50_000, 0])
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(50_000)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge invoice items on repayment' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge!(invoice_amount: Money.new(50_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to eq([50_000])
      expect(@invoice.invoice_items.map(&:amount_charged_cents)).to match_array([50_000, 0])

      expect { @invoice.charge!(invoice_amount: Money.new(50_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to eq([50_000, 50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([100_000, 0])

      expect { @invoice.charge!(invoice_amount: Money.new(100_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([50_000, 50_000, 50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([150_000, 0])

      expect { @invoice.charge!(invoice_amount: Money.new(110_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([50_000, 50_000, 50_000, 50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 0])

      expect { @invoice.charge!(invoice_amount: Money.new(30_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([50_000, 50_000, 50_000, 50_000, 50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 50_000])

      expect { @invoice.charge!(invoice_amount: Money.new(60_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1).and change { @invoice.reload.status }.to('paid')
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([50_000, 50_000, 50_000, 50_000, 50_000, 50_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to match_array([200_000, 100_000])
    end

    it 'should charge invoice items on repayment' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'processed', external_id: '123456', error: nil })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge!(invoice_amount: Money.new(@invoice.amount_cents - 100_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(2)
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([100_000, 200_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to eq([200_000, 100_000])
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(300_000)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')

      expect { @invoice.charge!(invoice_amount: Money.new(@invoice.amount_cents - 300_000)) }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      expect { post 'http://localhost:3000/dwolla/events', params: { resourceId: '123456', topic: 'transfer_completed' }, headers: @headers, as: :json }.to change { @payment_schedule_item.payment_schedule.account.transactions.credit.count }.by(1).and change { @invoice.reload.status }.to('paid')
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents)).to match_array([100_000, 100_000, 200_000])
      expect(@invoice.invoice_items.reload.map(&:amount_charged_cents)).to eq([200_000, 200_000])
      expect(@payment_schedule_item.payment_schedule.account.transactions.credit.map(&:principal_cents).inject(0, &:+)).to eq(400_000)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('processed')
      expect(payment.external_id).to eq('123456')
    end

    it 'should charge an invoice with payment method ach and payment service error' do
      allow_any_instance_of(PaymentService::Service).to receive(:collect_payment).and_return({ status: 'error', external_id: '123456', error: 'cannot process payment for now' })
      create(:payment_method_ach, resource: @customer, is_default: true)
      expect { @invoice.charge! }.to change { @invoice.invoice_payments.count }.by(1).and change { Payment.where(resource: @invoice.customer).count }.by(1)
      payment = Payment.where(resource: @invoice.customer).first
      expect(payment.status).to eq('error')
      expect(payment.error_message).to eq('cannot process payment for now')
      expect(payment.external_id).to eq('123456')
    end

    it 'should raise an error if default payment method is not found' do
      expect { @invoice.charge! }.to raise_error('no payment_method found on customer account')

      create(:payment_method_invoice, resource: @customer, is_default: false)
      expect { @invoice.charge! }.to raise_error('no payment_method found on customer account')
    end

    it 'should raise an error when external_id is not providded for invoice payment' do
      create(:payment_method_invoice, resource: @customer, is_default: true)
      expect { @invoice.charge! }.to raise_error('valid external_id is required in case of payment_method invoice')
    end
  end

  context 'post!' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @contact.update(primary: true)
      create(:payment_method_ach, is_default: true, resource: @contact.customer)
      order = create(:order, customer: @customer, interest_rate: 0.12, interest_rate_subsidy: 0.12, amount: 1440, billing_frequency: 'monthly')
      first_order_item = create(:order_item, order: order, quantity: 1, unit_price_cents: 2_000)
      second_order_item = create(:order_item, order: order, quantity: 1, unit_price_cents: 2_000)
      order.finance!
      payment_schedule_item = order.account.payment_schedule.payment_schedule_items.first
      @invoice = @contact.customer.invoices.create(amount: 4_000, due_date: Date.current + 7.days)
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '1',
                                     description: '1 description',
                                     payment_schedule_item: payment_schedule_item,
                                     order_item: first_order_item)
      @invoice.invoice_items.create!(amount: 2_000,
                                     name: '2',
                                     description: '2 description',
                                     payment_schedule_item: payment_schedule_item,
                                     order_item: second_order_item)
    end

    it 'should set posted date as current date if not paid' do
      expect(@invoice.post!).to be true
      expect(@invoice.posted_date).to eq(Date.today)
    end

    it 'should not update add posted date if  paid' do
      @invoice.update(status: :paid)
      expect { @invoice.post! }.to raise_error(StandardError)
    end
  end
end
