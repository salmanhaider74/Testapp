module Underwriting::Processors::Dnb
  ALL_NET_HTTP_ERRORS = [
    Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
  ].freeze

  SANDBOX_DUNS_NUMBER = %w[362428687 41091682 52792968 43178915].freeze

  class Client
    def initialize
      @token = generate_token
    end

    def get_json_report(duns_number)
      url = URI("https://plus.dnb.com/v1/data/duns/#{duns_number}?productId=cmptcs&versionId=v1")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['accept'] = 'application/json;charset=utf-8'
      request['authorization'] = "Bearer #{@token}"

      response = JSON.parse(http.request(request).read_body)
      raise 'Invalid D&B response' if response.key?('error')

      response
    end

    def get_pdf_report(duns_number)
      url = URI("https://plus.dnb.com/v1/reports/duns/#{duns_number}?productId=comprh&inLanguage=en-US&reportFormat=HTML")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['accept'] = 'application/json;charset=utf-8'
      request['authorization'] = "Bearer #{@token}"

      response = JSON.parse(http.request(request).read_body)
      raise 'Invalid D&B response' if response.key?('error')

      html = Base64.decode64(response['contents'][0]['contentObject'])
      StringIO.new(WickedPdf.new.pdf_from_string(html, zoom: 1.4))
    end

    def get_duns_number(customer)
      return SANDBOX_DUNS_NUMBER.sample unless Rails.env.production?

      params = [
        "name=#{customer.name}",
        "duns=#{customer.duns_number}",
        "streetAddressLine1=#{customer.default_address.try(:street)}",
        "streetAddressLine2=#{customer.default_address.try(:suite)}",
        "countryISOAlpha2Code=#{customer.default_address.try(:country)}",
        "postalCode=#{customer.default_address.try(:zip)}",
        "addressLocality=#{customer.default_address.try(:city)}",
        "addressRegion=#{customer.default_address.try(:state)}",
        "addressCounty=#{customer.default_address.try(:country)}"
      ]
      endpont = 'https://plus.dnb.com/v1/match/cleanseMatch'
      url = URI("#{endpont}?#{params.join('&')}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['accept'] = 'application/json'
      request['authorization'] = "Bearer #{@token}"
      response = http.request(request)
      res = JSON.parse(response.read_body)
      duns = ''
      duns = res['matchCandidates'][0]['organization']['duns'] if res['matchCandidates'].count.positive? && res['matchCandidates'][0]['organization'].present? && res['matchCandidates'][0]['organization']['duns'].present?

      duns
    rescue *ALL_NET_HTTP_ERRORS
      "Error: #{e}"
    end

    private

    def generate_token
      url = URI('https://plus.dnb.com/v2/token')

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['accept'] = 'application/json;charset=utf-8'
      request['Authorization'] = "Basic #{auth_token}"
      request['content-type'] = 'application/json'
      request.body = '{"grant_type":"client_credentials"}'
      response = http.request(request)
      JSON.parse(response.read_body)['access_token']
    rescue *ALL_NET_HTTP_ERRORS
      "Error: #{e}"
    end

    def auth_token
      Base64.strict_encode64("#{Rails.application.credentials[:dnb][:api_key]}:#{Rails.application.credentials[:dnb][:api_secret]}")
    end
  end
end
