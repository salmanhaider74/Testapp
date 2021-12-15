Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # TODO: add stg/prod urls later
    origins 'http://localhost:3001', 'http://localhost:3000', 'http://localhost:3002', 'http://localhost:4000', 'https://s.v.vartana.co', 'https://s.c.vartana.co', 'https://vendor.vartana.co', 'https://customer.vartana.co'
    resource '/graphql', methods: [:get, :post, :patch, :put], credentials: true
    resource '/vendor/graphql', methods: [:get, :post, :patch, :put], credentials: true
    resource '/set-cookie', methods: [:post], credentials: true

    resource '/plaid/link_token', methods: [:get], credentials: true
    resource '/plaid/public_token', methods: [:post], credentials: true
    resource '/plaid/institution', methods: [:get], credentials: true
    resource '/plaid/account', methods: [:get], credentials: true

    resource '/persona/verification_summary', methods: [:get], credentials: true
    resource '/persona/initiate_inquiry', methods: [:post], credentials: true
    resource '/persona/resume_inquiry', methods: [:post], credentials: true
    resource '/persona/event', methods: [:post], credentials: true

    resource '/dwolla/events', methods: [:post], credentials: true

    resource '/signin', methods: [:post], credentials: true # Keeping it for backward compatibility
    resource '/vendor/signin', methods: [:post], credentials: true
  end
end
