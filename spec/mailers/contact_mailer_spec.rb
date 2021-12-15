require 'rails_helper'

RSpec.describe ContactMailer, type: :mailer do
  context 'send_application!' do
    before do
      @vendor = create(:vendor)
      @product = create(:product, vendor: @vendor)
      @customer = create(:customer, vendor: @vendor)
      @contact = create(:contact, customer: @customer)
      @order = create(:order, customer: @contact.customer)
      @session = create(:session, resource: @contact, order: @order)
    end

    it 'should generate headers and body' do
      token = JsonWebToken.encode({ tkn: @session.token })
      mail = ContactMailer.with(session: @session, contact: @contact).order_application

      expect(mail.subject).to match(@order.vendor.name)
      expect(mail.to).to eq([@contact.email])
      expect(mail.from.first).to match('financing@')
      expect(mail.body.encoded).to match(token)
    end
  end
end
