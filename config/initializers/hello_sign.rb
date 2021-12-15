require 'hello_sign'

HelloSign.configure do |config|
  config.api_key = Rails.application.credentials[:hellosign][:api_key]
end
