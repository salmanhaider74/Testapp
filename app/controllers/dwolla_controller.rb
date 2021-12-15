class DwollaController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token
  before_action :verify_signature

  def event
    case params[:topic]
    when 'transfer_completed'
      external_id = params['resourceId']
      render json: { message: 'Dwolla Event Received' } and return if external_id.nil?

      payment = Payment.where(external_id: external_id).first
      render json: { message: 'Dwolla Event Received' } and return if payment.nil?

      payment.update(status: 'processed')
      if payment.reload.status == 'processed' && payment.resource.is_a?(Customer)
        payment.invoice_payments.each do |invoice_payment|
          invoice = invoice_payment.invoice
          invoice.credit_account!(payment)
          invoice.update!(status: 'paid') if invoice.invoice_payments.map { |p| p.payment.amount_cents }.inject(0, &:+) == invoice.amount_cents
        end
      end
    when 'customer_funding_source_verified'
      payment_method = PaymentMethod.where(funding_source: params['_links']['resource']['href']).first
      payment_method.update!(verified: true) if payment_method.present?
    end
    render json: { message: 'Dwolla Event Received' }
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  def verify_signature
    payload = request.body.read
    sig_header = request.env['HTTP_X_REQUEST_SIGNATURE_SHA_256']
    expected = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), Rails.application.credentials[:secret_key_base], payload)

    render status: :forbidden, json: { message: 'Invalid Event' } and return unless expected == sig_header
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
