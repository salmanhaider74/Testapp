class VendorMailer < ApplicationMailer
  before_action :set_values

  def from_vartana_email
    domain = Rails.env.staging? ? 's.vartana.co' : 'vartana.co'
    "Vartana <financing@#{domain}>"
  end

  default to: -> { [@vendor.contact_email, @order.user.try(:email)] }, from: -> { from_vartana_email }

  def order_preapproved
    mail(subject: "[ACTION REQUIRED] Approve hard check for order #{@order.number} / #{@order.customer.name}") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def order_not_approved_need_consent_fullcheck
    mail(subject: "[ACTION REQUIRED] Approve hard check for order# #{@order.number} / #{@order.customer.name}") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def need_financial_review
    mail(subject: "[ACTION REQUIRED] Send application link for order#  #{@order.number} / #{@order.customer.name}") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def need_sales_order
    mail(subject: "[ACTION REQUIRED] Upload sales order for order# #{@order.number} / #{@order.customer.name}") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def checkout_ready
    mail(subject: "[ACTION REQUIRED] Send checkout link for order# #{@order.number} / #{@order.customer.name}") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def need_invoice
    attachments['agreement.pdf'] = { mime_type: @order.agreement.blob.content_type, content: @order.agreement.blob.download }
    mail(subject: "[ACTION REQUIRED] Upload invoice for order# #{@order.number} / #{@order.customer.name}") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def order_complete
    mail(subject: "Order # #{@order.number} for #{@order.customer.name} is financed") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  def order_declined
    mail(subject: "Order # #{@order.number} for #{@order.customer.name} is declined") do |format|
      format.html { render layout: 'vendor_mailer' }
      format.text { render layout: 'vendor_mailer' }
    end
  end

  private

  def set_values
    @order = params[:order]
    @vendor = @order.customer.vendor
    @url = "#{Rails.application.credentials[:vendor_app_url]}/dashboard/orders/#{@order.number}/show"
  end
end
