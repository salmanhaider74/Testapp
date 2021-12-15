class CallbackController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token

  def create
    event = ActiveSupport::JSON.decode(params[:json])
    if event['event'].present? && Signature.verify_signature_event(event['event'])
      signature_request_id = event['signature_request']['signature_request_id']
      if event['event']['event_type'] == 'signature_request_all_signed' && signature_request_id.present?
        order = Order.where(signature_request_id: signature_request_id).first
        if order.present? && !order.agreement.present?
          signed_agreement = Signature.get_signed_agreement(order.signature_request_id)
          order.agreement = ActiveStorage::Blob.create_and_upload!(
            io: URI.parse(signed_agreement['file_url']).open,
            filename: 'SignedAgreement.pdf',
            content_type: 'application/pdf'
          )
          order.manual_review = true
          order.save!
          VendorMailer.with({ order: order }).need_invoice.deliver_later
        end
      end
      render json: { message: 'Hello API Event Received' }
    else
      render status: :forbidden, json: { message: 'Invalid Event' }
    end
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
