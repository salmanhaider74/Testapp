Sidekiq.configure_server do |config|
  redis_config = Rails.application.credentials[:redis]
  config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  redis_config = Rails.application.credentials[:redis]
  config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/#{Rails.env}" }
end
