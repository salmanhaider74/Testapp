class InvoiceMailer < ApplicationMailer
  before_action :set_contact

  default to: -> { @contact.email },
          from: -> { @contact.customer.vendor.from_email }

  def invoice_summary
    attachments['invoice.pdf'] = { mime_type: @invoice.pdf.blob.content_type, content: @invoice.pdf.blob.download }
    mail(subject: 'Your invoice is ready!')
  end

  private

  def set_contact
    @contact = params[:contact]
    @invoice = params[:invoice]
    @vendor = @contact.customer.vendor
  end
end
