module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?, :guest_user?
  end

  def current_user
    @current_user ||= find_current_user
  end

  def logged_in?
    current_user.present?
  end

  def guest_user?
    current_user&.guest?
  end

  def require_login
    unless logged_in?
      store_location
      redirect_to new_session_path, alert: t('errors.login_required', default: 'Debes iniciar sesión')
    end
  end

  def require_registered_user
    if guest_user?
      store_location
      redirect_to new_registration_path, alert: t('errors.registration_required', default: 'Debes crear una cuenta')
    elsif !logged_in?
      store_location
      redirect_to new_session_path
    end
  end

  def login(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
    @current_user = user
  end

  def logout
    @current_user&.regenerate_session_token! if @current_user&.guest?
    session.delete(:user_id)
    session.delete(:session_token)
    @current_user = nil
  end

  def create_or_find_guest!
    return current_user if logged_in?

    guest = User.create_guest!
    login(guest)
    guest
  end

  private

  def find_current_user
    return nil unless session[:user_id] && session[:session_token]

    user = User.find_by(id: session[:user_id])
    return nil unless user
    return nil unless user.session_token == session[:session_token]

    user
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session.delete(:return_to) || default)
  end
end
