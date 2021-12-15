class JsonWebToken
  def self.encode(payload)
    JWT.encode(payload, Rails.application.credentials[:jwt_secret])
  end

  def self.decode(token)
    HashWithIndifferentAccess.new(JWT.decode(token, Rails.application.credentials[:jwt_secret])[0])
  rescue StandardError
    nil
  end
end
