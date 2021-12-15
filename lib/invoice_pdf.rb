class InvoicePdf
  def self.generate_invoice_pdf(invoice)
    controller = ActionController::Base.new
    html_rendered = controller.render_to_string template: 'layouts/invoice.html.erb',
                                                locals: {
                                                  invoice: invoice,
                                                  contact: invoice.customer.primary_contact,
                                                  customer: invoice.customer,
                                                  vendor: invoice.customer.vendor,
                                                  invoice_items: invoice.invoice_items.blank? ? [] : invoice.invoice_items,
                                                  default_payment_method: invoice.customer.default_payment_method,
                                                }

    content = WickedPdf.new.pdf_from_string(html_rendered)
    path = Rails.root.join('tmp', 'invoice.pdf')
    File.open(path, 'wb') { |file| file << content }
    path
  rescue StandardError => e
    "Error: #{e}"
  end
end
