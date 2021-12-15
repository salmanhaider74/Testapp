require 'faraday'

class PersonaService
  class << self
    def client
      @@client = Faraday.new(
        url: 'https://withpersona.com/api/v1',
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{Rails.application.credentials[:persona][:bearer]}",
          'Key-Inflection' => 'snake',
          'Persona-Version' => '2020-01-13',
        }
      ) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response :json
      end
    end

    def inquiries
      client.get 'inquiries'
    end

    def inquiry(inquiry_id)
      client.get "inquiries/#{inquiry_id}"
    end

    def resume_inquiry(inquiry_id)
      client.post "inquiries/#{inquiry_id}/resume"
    end

    def verification(verification_id)
      client.get "verifications/#{verification_id}"
    end
  end
end
