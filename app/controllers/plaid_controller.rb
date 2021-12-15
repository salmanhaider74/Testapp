class PlaidController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token

  before_action :require_cookie

  def require_cookie
    jwt = cookies.signed[:jwt]
    if jwt.present?
      decoded = JsonWebToken.decode(jwt)
      if decoded.present?
        session = Session.authenticate(decoded[:tkn])
        params[:session] = session
      else
        head :bad_request
      end
    else
      head :bad_request
    end
  end

  def link_token
    session = params[:session]
    unique_id = "Customer-#{session.resource.customer.duns_number}-#{session.resource.customer.id}"
    token = PlaidService.get_link_token(unique_id, session.resource.customer.vendor.test_mode)
    render json: { token: token }
  end

  def public_token
    session = params[:session]

    if params[:public_token].present? && params[:account_id].present?
      response = PlaidService.exchange_public_token(params[:public_token], session.resource.customer.vendor.test_mode)
      payment_method = PaymentMethod.find_or_initialize_by(resource: session.resource.customer)
      payment_method.save! if payment_method.id.nil?
      plaid_token = PlaidToken.find_or_initialize_by(resource: payment_method, account_id: params[:account_id])

      PlaidService.remove_item(plaid_token.access_token, session.resource.customer.vendor.test_mode) if plaid_token.access_token.present?

      plaid_token.update!(
        access_token: response.access_token,
        item_id: response.item_id,
        request_id: response.request_id
      )

      payment_method.update!(payment_mode: :plaid)

      render json: { payment_method_id: payment_method.id }
    else
      head :bad_request
    end
  end

  def account
    session = params[:session]

    payment_method = PaymentMethod.where(resource: session.resource.customer, payment_mode: :plaid).last
    head :not_found and return unless payment_method.present?

    plaid_token = PlaidToken.where(resource: payment_method).last
    head :not_found and return unless plaid_token.present?

    begin
      test_mode = session.resource.customer.vendor.test_mode
      accounts_response = PlaidService.get_accounts(plaid_token.access_token, test_mode, account_ids: [plaid_token.account_id])
      institution_response = PlaidService.get_institution_by_id(accounts_response.item.institution_id, test_mode)['institution']
      payment_method.update!(account_name: accounts_response.accounts[0].name, account_type: accounts_response.accounts[0].type, account_number: accounts_response.accounts[0].mask, bank: institution_response.name)
      accounts_response.set_value_with_coercion(:institution, institution_response)
      render json: accounts_response.to_json
    rescue Plaid::InvalidInputError
      head :not_found
    end
  end

  def institution
    institution_id = params[:institution_id]

    response_json = PlaidService.get_institution_by_id(institution_id, session.resource.customer.vendor.test_mode)['institution'].to_json
    render json: response_json
  end
end
