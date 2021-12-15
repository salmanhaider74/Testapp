# To Run: OneOffs::AttachPdfsToInvoices.run
module OneOffs
  class AttachPdfsToInvoices
    def self.run
      Invoice.all.each do |inv|
        next unless !inv.pdf.attached? && inv.customer.default_payment_method.present?

        inv.pdf = ActiveStorage::Blob.create_and_upload!(
          io: File.open(InvoicePdf.generate_invoice_pdf(inv)),
          filename: "#{inv.number}.pdf",
          content_type: 'application/pdf'
        )
        inv.save!
      end
    end
  end
end
