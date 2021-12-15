class ContactMailer < ApplicationMailer
  before_action :set_contact

  default to: -> { @contact.email },
          from: -> { @contact.customer.vendor.from_email }

  def order_application
    @session = params[:session]
    @vendor = @session.order.customer.vendor
    @url = "#{Rails.application.credentials[:customer_app_url]}/checkout?t=#{JsonWebToken.encode({ tkn: @session.token })}"
    mail(subject: "Your application for #{@vendor.name.titleize} order is ready")
  end

  def checkout_order
    @session = params[:session]
    @vendor = @session.order.customer.vendor
    @url = "#{Rails.application.credentials[:customer_app_url]}/checkout?t=#{JsonWebToken.encode({ tkn: @session.token })}"
    mail(subject: "Your #{@vendor.name.titleize} order is ready for checkout")
  end

  private

  def set_contact
    @contact = params[:contact]
  end
end
