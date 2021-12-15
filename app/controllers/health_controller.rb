class HealthController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token

  def ok
    head :ok
  end
end
