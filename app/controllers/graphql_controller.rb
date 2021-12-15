class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    # TODO: update current IP address if it is different
    jwt = cookies.signed[:jwt]
    if jwt.present?
      decoded = JsonWebToken.decode(jwt)
      session = Session.authenticate(decoded[:tkn]) if decoded.present?
      if session.present?
        resource = session.resource
        context  = { current_session: session }
        if resource.is_a?(User)
          context.merge!(current_vendor: resource.vendor, current_user: resource)
        else
          context.merge!(current_customer: resource.customer, current_order: session.order, current_contact: resource)
        end
        cookies.signed[:jwt] = { value: jwt, httponly: true }
      end
    end
    schema = session.present? && session.contact.present? ? CustomerAppSchema : VendorAppSchema
    result = schema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
