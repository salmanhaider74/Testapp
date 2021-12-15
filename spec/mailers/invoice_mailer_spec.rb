require 'rails_helper'

RSpec.describe InvoiceMailer, type: :mailer do
  context 'invoice_email' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @contact.update(primary: true)
      create(:payment_method_ach, is_default: true, resource: @contact.customer)
      order = create(:order, interest_rate: 0.12, interest_rate_subsidy: 0.12, amount: 1440, customer: @contact.customer)
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

    it 'should generate headers and body' do
      mail = InvoiceMailer.with({ contact: @contact,
                                  invoice: @invoice, }).invoice_summary

      expect(mail.subject).to match('Your invoice is ready!')
      expect(mail.to).to eq([@contact.email])
      expect(mail.from.first).to match('financing@')
      expect(mail.body.encoded).to match(@contact.full_name)

      expect(mail.attachments.count).to eq(1)
      attachment = mail.attachments[0]
      expect(attachment).to be_a_kind_of(Mail::Part)
      expect(attachment.content_type).to be_start_with('application/pdf')
      expect(attachment.filename).to eq('invoice.pdf')
    end
  end
end
