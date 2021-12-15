if Rails.env.staging? || Rails.env.production?
  def create_webhook
    dwolla = DwollaV2::Client.new(
      key: Rails.application.credentials[:dwolla][:key],
      secret: Rails.application.credentials[:dwolla][:secret],
      environment: Rails.application.credentials[:dwolla][:env]
    ) do |config|
      config.faraday do |faraday|
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end
    client = dwolla.auths.client
    webhook_subscriptions = client.get 'webhook-subscriptions'
    if webhook_subscriptions.total < 1
      request_body = {
        url: Rails.application.credentials[:dwolla][:event_url],
        secret: Rails.application.credentials[:secret_key_base],
      }
      client.post 'webhook-subscriptions', request_body
    end
  rescue DwollaV2::NotFoundError => e
    "Error: #{e.code}"
  rescue DwollaV2::Error => e
    "Error: #{e}"
  end

  create_webhook
end
