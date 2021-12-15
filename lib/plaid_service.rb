require 'plaid'

class PlaidService
  class << self
    def country_codes
      @@country_codes = ['US']
    end

    def products
      @@products = %w[auth identity balance]
    end

    def client
      @@client = Plaid::Client.new(
        env: Rails.application.credentials[:plaid][:env],
        client_id: Rails.application.credentials[:plaid][:client_id],
        secret: Rails.application.credentials[:plaid][:secret]
      )
    end

    def sandbox_client
      @@client = Plaid::Client.new(
        env: Rails.application.credentials[:plaid_sandbox][:env],
        client_id: Rails.application.credentials[:plaid_sandbox][:client_id],
        secret: Rails.application.credentials[:plaid_sandbox][:secret]
      )
    end

    def get_link_token(client_user_id, test_mode)
      plaid_client = test_mode ? sandbox_client : client
      link_token_response = plaid_client.link_token.create(
        user: { client_user_id: client_user_id.to_s },
        client_name: 'Vartana',
        products: %w[auth identity],
        country_codes: country_codes,
        language: 'en'
      )
      link_token_response.link_token
    end

    def exchange_public_token(public_token, test_mode)
      plaid_client = test_mode ? sandbox_client : client
      plaid_client.item.public_token.exchange(public_token)
    end

    def get_processor_token(access_token, account_id, test_mode)
      plaid_client = test_mode ? sandbox_client : client
      create_response = plaid_client.processor.processor_token.create(access_token, account_id, 'dwolla')
      create_response.processor_token
    end

    def get_accounts(access_token, test_mode, account_ids: nil)
      plaid_client = test_mode ? sandbox_client : client
      plaid_client.accounts.get(access_token, account_ids: account_ids)
    end

    def get_item(access_token, test_mode)
      plaid_client = test_mode ? sandbox_client : client
      plaid_client.item.get(access_token)
    end

    def remove_item(access_token, test_mode)
      plaid_client = test_mode ? sandbox_client : client
      plaid_client.item.remove(access_token)
    end

    def get_institutions(test_mode, count = 10, offset = 0)
      plaid_client = test_mode ? sandbox_client : client
      response = plaid_client.institutions.get(
        count: count,
        offset: offset,
        country_codes: country_codes,
        options: {
          products: products,
        }
      )
      response['institutions']
    end

    def get_institution_by_id(id, test_mode)
      options = {
        include_optional_metadata: true,
      }
      plaid_client = test_mode ? sandbox_client : client
      plaid_client.institutions.get_by_id(id, country_codes, options: options)
    end
  end
end
