# Preview all emails at http://localhost:3000/rails/mailers/vendor_mailer
class VendorMailerPreview < ActionMailer::Preview
  def self.define_mailer_preview(name)
    define_method(name) do
      VendorMailer.with({ order: Order.last }).send(name)
    end
  end

  define_mailer_preview :order_preapproved
  define_mailer_preview :order_not_approved_need_consent_fullcheck
  define_mailer_preview :order_complete
  define_mailer_preview :order_declined
  define_mailer_preview :need_invoice
  define_mailer_preview :need_financial_review
  define_mailer_preview :checkout_ready
end
