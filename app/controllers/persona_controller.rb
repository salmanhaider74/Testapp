class PersonaController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token

  before_action :require_cookie, except: [:event]

  def event
    event_authenticated = lambda do |secret, &block|
      t, v1 = request.headers['Persona-Signature'].split(',').map { |value| value.split('=').second }
      computed_digest = OpenSSL::HMAC.hexdigest('SHA256', secret, "#{t}.#{request.body.read}")
      if v1 == computed_digest
        # Handle verified webhook event
        block.call
        head :ok
      else
        # Invalid request signature
        head :forbidden
      end
    end

    body = JSON.parse(request.body.read)
    event_name = body.dig('data', 'attributes', 'name')
    case event_name
    when 'inquiry.completed'
      event_authenticated.call Rails.application.credentials[:persona][:webhook_events][:inquiry][:completed] do
        payload = body.dig('data', 'attributes', 'payload')
        inquiry_id = payload.dig('data', 'id')
        status = payload.dig('data', 'attributes', 'status')
        contact = Contact.where(inquiry_id: inquiry_id).first
        first_name = payload.dig('data', 'attributes', 'name_first')
        last_name = payload.dig('data', 'attributes', 'name_last')
        contact.update!(verified_at: Time.now) if (contact.present? && status == 'completed') && (contains_in_other?(contact.first_name, first_name) && contains_in_other?(contact.last_name, last_name))
        head :ok
      end
    end
  end

  def require_cookie
    jwt = cookies.signed[:jwt]
    if jwt.present?
      decoded = JsonWebToken.decode(jwt)
      if decoded.present?
        session = Session.authenticate(decoded[:tkn])
        params[:session] = session
      else
        head :bad_request
      end
    else
      head :bad_request
    end
  end

  def initiate_inquiry
    session = params[:session]
    if params[:inquiry_id].present?
      contact = Contact.find_by(id: session.resource.id)
      contact.update!(
        inquiry_id: params[:inquiry_id]
      )
      head :ok
    else
      head :bad_request
    end
  end

  def resume_inquiry
    if params[:inquiry_id].present?
      resume_inquiry = PersonaService.resume_inquiry params[:inquiry_id]
      inquiry = PersonaService.inquiry params[:inquiry_id]
      resume_inquiry_response = resume_inquiry.body
      inquiry_response = inquiry.body
      render json: {
        session_token: resume_inquiry_response.dig('meta', 'session_token') || '',
        inquiry_status: inquiry_response.dig('data', 'attributes', 'status') || '',
      }
    else
      head :bad_request
    end
  end

  def verification_summary
    session = params[:session]

    if params[:inquiry_id].present?
      inquiry = PersonaService.inquiry params[:inquiry_id]
      inquiry_response = inquiry.body

      status = inquiry_response.dig('data', 'attributes', 'status')
      first_name = inquiry_response.dig('data', 'attributes', 'name_first')
      last_name = inquiry_response.dig('data', 'attributes', 'name_last')

      status = 'invalid_contact' unless contains_in_other?(session.resource.first_name, first_name) || contains_in_other?(session.resource.last_name, last_name)

      render json: {
        status: status,
        type: inquiry_response.dig('data', 'relationships', 'verifications', 'data', 0, 'type'),
        name_first: first_name,
        name_middle: inquiry_response.dig('data', 'attributes', 'name_middle'),
        name_last: last_name,
        driver_license_number: inquiry_response.dig('data', 'attributes', 'driver_license_number'),
      }
    else
      head :bad_request
    end
  end

  private

  def contains_in_other?(str_a, str_b)
    str_a.downcase.include?(str_b.downcase) || str_b.downcase.include?(str_a.downcase)
  end
end
