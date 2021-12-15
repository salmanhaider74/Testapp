require 'rails_helper'

RSpec.describe VendorMailer, type: :mailer do
  context 'order_preapproved' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).order_preapproved

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end
  context 'order_not_approved_need_consent_fullcheck' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).order_not_approved_need_consent_fullcheck

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end

  context 'order_declined' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).order_declined

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end

  context 'order_complete' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).order_complete

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end

  context 'need_sales_order' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).need_sales_order

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end

  context 'need_invoice' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
      @order.agreement.attach(io: File.open('./spec/fixtures/test.pdf'), filename: 'agreement.pdf')
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).need_invoice

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end

  context 'need_financial_review' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).need_financial_review

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end

  context 'checkout_ready' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
    end

    it 'should generate headers and body' do
      mail = VendorMailer.with(order: @order).checkout_ready

      expect(mail.subject).to match(@order.customer.name)
      expect(mail.to).to eq([@vendor.contact_email])
      expect(mail.from.first).to match('financing@')
    end
  end
end
