# Preview all emails at http://localhost:3000/rails/mailers/invoice_mailer
class InvoiceMailerPreview < ActionMailer::Preview
  def invoice_summary
    InvoiceMailer.with({
      contact: Session.where(resource_type: 'Contact').first.resource,
      invoice: Invoice.last,
    }).invoice_summary
  end
end
