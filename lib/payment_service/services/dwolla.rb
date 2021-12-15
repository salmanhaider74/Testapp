module PaymentService
  class Services::Dwolla
    def collect_payment(payment_method, invoice_amount)
      payin_account = payment_method.test_mode_enabled? ? Rails.application.credentials[:dwolla_sandbox][:master_account_payin] : Rails.application.credentials[:dwolla][:master_account_payin]
      response = transfer(payment_method.funding_source, payin_account, invoice_amount, payment_method.test_mode_enabled?, currency: 'USD')
      { status: response[:status], external_id: response[:external_id], error: response[:error] }
    end

    def payout(_vendor, amount, payment_method)
      payout_account = payment_method.test_mode_enabled? ? Rails.application.credentials[:dwolla_sandbox][:master_account_payout] : Rails.application.credentials[:dwolla][:master_account_payout]
      response = transfer(payout_account, payment_method.funding_source, amount, payment_method.test_mode_enabled?, currency: 'USD')
      { status: response[:status], external_id: response[:external_id], error: response[:error] }
    end

    def create_account(dw_account, receive_only)
      primary_contact = dw_account.resource.is_a?(Vendor) ? dw_account.resource.users.first : dw_account.resource.primary_contact
      request_body = {
        firstName: primary_contact.first_name,
        lastName: primary_contact.last_name,
        email: primary_contact.email,
        businessName: dw_account.resource.name,
      }

      request_body.merge!({ type: 'receive-only' }) if receive_only

      test_mode = dw_account.resource.is_a?(Vendor) ? dw_account.resource.test_mode : dw_account.resource.vendor.test_mode
      dw_client = test_mode ? sandbox_client : client
      customer = dw_client.post 'customers', request_body
      dw_account.update!(url: customer.response_headers[:location])
    rescue DwollaV2::NotFoundError => e
      "Error: #{e.code}"
    rescue DwollaV2::Error => e
      "Error: #{e}"
    end

    def create_funding_source(dw_account, payment_method)
      if payment_method.plaid? && payment_method.plaid_token.access_token.present? && payment_method.plaid_token.account_id.present?
        processor_token = PlaidService.get_processor_token(payment_method.plaid_token.access_token, payment_method.plaid_token.account_id, payment_method.test_mode_enabled?)
        req_body = {
          plaidToken: processor_token,
          name: payment_method.account_name,
        }
      else
        req_body = {
          routingNumber: Rails.application.credentials[:dwolla][:env] == 'sandbox' ? '222222226' : payment_method.routing_number,
          accountNumber: Rails.application.credentials[:dwolla][:env] == 'sandbox' ? '123456789' : payment_method.account_number_unmasked,
          bankAccountType: payment_method.account_type,
          name: payment_method.account_name,
        }
      end

      dw_client = payment_method.test_mode_enabled? ? sandbox_client : client
      funding_source = dw_client.post "#{dw_account.url}/funding-sources", req_body
      payment_method.update!(funding_source: funding_source.response_headers[:location])
      initiate_micro_deposits(payment_method.reload) unless payment_method.plaid?
    rescue DwollaV2::NotFoundError => e
      "Error: #{e.code}"
    rescue DwollaV2::Error => e
      "Error: #{e}"
    end

    def initiate_micro_deposits(payment_method)
      dw_client = payment_method.test_mode_enabled? ? sandbox_client : client
      dw_client.post "#{payment_method.funding_source}/micro-deposits"
      verify_micro_deposits(payment_method.reload) if Rails.application.credentials[:dwolla][:env] == 'sandbox'
    rescue DwollaV2::NotFoundError => e
      "Error: #{e.code}"
    rescue DwollaV2::Error => e
      "Error: #{e}"
    end

    def verify_micro_deposits(payment_method)
      request_body = {
        amount1: {
          value: '0.03',
          currency: 'USD',
        },
        amount2: {
          value: '0.09',
          currency: 'USD',
        },
      }

      dw_client = payment_method.test_mode_enabled? ? sandbox_client : client
      dw_client.post "#{payment_method.funding_source}/micro-deposits", request_body
    rescue DwollaV2::NotFoundError => e
      "Error: #{e.code}"
    rescue DwollaV2::Error => e
      "Error: #{e}"
    end

    def transfer(source, destination, amount, test_mode, currency: 'USD')
      request_body = {
        _links: {
          source: {
            href: source,
          },
          destination: {
            href: destination,
          },
        },
        amount: {
          currency: currency,
          value: amount,
        },
      }

      dw_client = test_mode ? sandbox_client : client
      transfer = dw_client.post 'transfers', request_body
      { external_id: transfer.response_headers[:location].split('/').last, status: 'pending', error: nil }
    rescue DwollaV2::NotFoundError, DwollaV2::Error => e
      { external_id: nil, status: 'error', error: e }
    end

    private

    def client
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
      @@client = dwolla.auths.client
    end

    def sandbox_client
      dwolla = DwollaV2::Client.new(
        key: Rails.application.credentials[:dwolla_sandbox][:key],
        secret: Rails.application.credentials[:dwolla_sandbox][:secret],
        environment: Rails.application.credentials[:dwolla_sandbox][:env]
      ) do |config|
        config.faraday do |faraday|
          faraday.response :logger
          faraday.adapter Faraday.default_adapter
        end
      end
      @@client = dwolla.auths.client
    end
  end
end
