module Underwriting::Processors::Middesk
  ALL_NET_HTTP_ERRORS = [
    Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
  ].freeze

  class Client
    def initialize; end

    def create_business(business_name, address)
      uri = URI("#{Rails.application.credentials[:middesk][:url]}/businesses")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri)
      request.basic_auth(Rails.application.credentials[:middesk][:key], '')
      request.content_type = 'application/json'
      request.body = JSON.dump({
        'name' => business_name,
        'addresses' => [
          {
            'address_line1' => address.try(:street),
            'address_line2' => address.try(:suite),
            'city' => address.try(:city),
            'state' => address.try(:state),
            'postal_code' => address.try(:zip),
          }
        ],
      })
      response = JSON.parse(http.request(request).read_body)
      raise 'Invalid Middesk response' if response.key?('errors')

      response['id']
    rescue *ALL_NET_HTTP_ERRORS
      "Error: #{e}"
    end

    def get_json_report(business_id)
      uri = URI("#{Rails.application.credentials[:middesk][:url]}/businesses/#{business_id}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri)
      request.basic_auth(Rails.application.credentials[:middesk][:key], '')
      request.content_type = 'application/json'

      response = JSON.parse(http.request(request).read_body)
      raise 'Invalid Middesk response' if response.key?('errors')

      response
    rescue *ALL_NET_HTTP_ERRORS
      "Error: #{e}"
    end

    def get_pdf_report(business_id)
      url = URI("#{Rails.application.credentials[:middesk][:url]}/businesses/#{business_id}/pdf")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['accept'] = 'application/json'
      request.basic_auth(Rails.application.credentials[:middesk][:key], '')
      response = http.request(request)
      raise 'Invalid Middesk response' unless response.code == '200'

      StringIO.new(response.read_body)
    end
  end
end
