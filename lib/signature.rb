require 'openssl'

class Signature
  def self.create_signature_request(file, contact)
    params = {
      test_mode: Rails.env.production? ? 0 : 1,
      client_id: Rails.application.credentials[:hellosign][:client_id],
      signers: [{
        email_address: contact.email,
        name: contact.full_name,
      }],
      files: [file],
      signing_options: {
        draw: true,
        type: true,
        upload: true,
        phone: true,
        default: 'draw',
      },
      use_text_tags: 1,
      hide_text_tags: 1,
    }
    signature_request = HelloSign.create_embedded_signature_request(params)
    signature_request.signature_request_id
  end

  def self.create_signature_request_url(signature_request_id)
    signature_request = HelloSign.get_signature_request({ signature_request_id: signature_request_id })
    signature_request.signatures.first.status_code == 'awaiting_signature' ? HelloSign.get_embedded_sign_url({ signature_id: signature_request.signatures.first.signature_id }).sign_url : ''
  end

  def self.get_signed_agreement(signature_request_id)
    HelloSign.signature_request_files({ signature_request_id: signature_request_id, get_url: true })
  end

  def self.verify_signature_event(event)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), Rails.application.credentials[:hellosign][:api_key], (event['event_time'] + event['event_type'])) == event['event_hash']
  end
end
