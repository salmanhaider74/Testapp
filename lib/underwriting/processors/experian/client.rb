module Underwriting::Processors::Experian
  ALL_NET_HTTP_ERRORS = [
    Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
  ].freeze

  SANDBOX_BINS = %w[400229390 402074624 402328597 402447320 407755441].freeze

  class Client
    def initialize
      @token = generate_token
    end

    def get_json_report(bin)
      url = URI("#{Rails.application.credentials[:experian][:api_url]}/businessinformation/businesses/v1/reports/premierprofiles")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['content-type'] = 'application/json'
      request['Authorization'] = "Bearer #{@token}"
      request.body = {
        "bin": bin,
        "subcode": Rails.env.production? ? '0582118' : '0517614',
        "modelCode": '000224',
      }.to_json

      response = http.request(request)
      rsp = JSON.parse(response.read_body)
      raise 'Invalid Experian response' if rsp.key?('errors')

      rsp
    end

    def get_pdf_report(bin)
      url = URI("#{Rails.application.credentials[:experian][:api_url]}/businessinformation/businesses/v1/reports/premierprofiles/pdf")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['content-type'] = 'application/json'
      request['authorization'] = "Bearer #{@token}"

      request.body = {
        "bin": bin,
        "subcode": Rails.env.production? ? '0582118' : '0517614',
        "modelCode": '000224',
      }.to_json

      response = JSON.parse(http.request(request).read_body)
      raise 'Invalid Experian response' if response.key?('errors')

      StringIO.new(Base64.decode64(response['results']))
    end

    def get_bin_number(customer)
      return SANDBOX_BINS.sample unless Rails.env.production?

      url = URI("#{Rails.application.credentials[:experian][:api_url]}/businessinformation/businesses/v1/search")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['accept'] = 'application/json'
      request['content-type'] = 'application/json'
      request['authorization'] = "Bearer #{@token}"

      request.body = {
        "name": customer.name.to_s,
        "city": customer.default_address.try(:city).to_s,
        "state": customer.default_address.try(:state).to_s,
        "street": customer.default_address.try(:street).to_s,
        "zip": customer.default_address.try(:zip).to_s,
        "subcode": Rails.env.production? ? '0582118' : '0517614',
        "geo": true,
      }.to_json
      response = http.request(request)
      raise 'Invalid Experian response' if response.key?('errors')

      res = JSON.parse(response.read_body)
      res.dig('results', 0, 'bin')
    rescue *ALL_NET_HTTP_ERRORS
      "Error: #{e}"
    end

    private

    def generate_token
      url = URI("#{Rails.application.credentials[:experian][:api_url]}/oauth2/v1/token")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(url)
      request['accept'] = 'application/json;charset=utf-8'
      request['content-type'] = 'application/json'
      request['client_id'] = Rails.application.credentials[:experian][:client_id]
      request['client_secret'] = Rails.application.credentials[:experian][:client_secret]
      request.body = {
        "username": Rails.application.credentials[:experian][:username],
        "password": Rails.application.credentials[:experian][:password],
      }.to_json

      response = http.request(request)
      JSON.parse(response.read_body)['access_token']
    rescue *ALL_NET_HTTP_ERRORS
      "Error: #{e}"
    end
  end
end
