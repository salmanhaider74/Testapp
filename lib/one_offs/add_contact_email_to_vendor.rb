# To Run: OneOffs::AddContactEmailToVendor.run
module OneOffs
  class AddContactEmailToVendor
    def self.run
      vendors = Vendor.all
      vendors.each do |vendor|
        vendor.contact_email = "support@#{vendor.domain}"
        vendor.email_preferences = { 'pre_approved_email' => true, 'checkout_ready_email' => true, 'order_financed_email' => true, 'order_declined_email' => true, 'need_sales_order_email' => true, 'need_financial_review_email' => true, 'agreement_signed_need_invoice_email' => true, 'not_approved_require_fullcheck_email' => true }
        vendor.save!
      end
    end
  end
end
