if Rails.env.staging? || Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    user_name: 'apikey',
    password: Rails.application.credentials[:sendgrid][:api_key],
    domain: 's.vartana.co',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }
end
