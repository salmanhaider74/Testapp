class CookieController < ApplicationController
  DEFAULT_APP_DAYS = 3.days.freeze
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  skip_before_action :verify_authenticity_token

  def create
    if params[:token].present?
      cookies.signed[:jwt] = { value: params[:token], httponly: true }
      render json: { success: true }
    else
      render json: { success: false }
    end
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  def signin
    render json: { error: 'Insufficient params provided' } and return if params[:email].nil? || params[:password].nil?

    user = User.find_by_email(params[:email])
    if user.present? && user.valid_password?(params[:password])
      session = Session.active.find_by(resource: user)
      if session.present?
        session.update!(expires_at: DEFAULT_APP_DAYS.from_now, current_ip: request.remote_ip, last_active_at: Time.now, sign_in_ip: request.remote_ip)
      else
        session = Session.create!(resource: user, expires_at: DEFAULT_APP_DAYS.from_now, current_ip: request.remote_ip, last_active_at: Time.now, sign_in_ip: request.remote_ip)
      end

      user.track_login!(request.remote_ip)
      path = request.path == '/signin' ? '/' : '/vendor'
      cookies.signed[:jwt] = { value: JsonWebToken.encode({ tkn: session.token }), httponly: true, path: path }
      render json: { success: true } and return
    end

    render json: { error: 'Incorrect username or password' }
  end

  private

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
