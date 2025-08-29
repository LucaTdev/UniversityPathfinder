class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= begin
      if session[:user_id]
        User.find_by(id: session[:user_id])
      elsif cookies.signed[:user_id]
        user = User.find_by(id: cookies.signed[:user_id])
        session[:user_id] = user.id if user
        user
      end
    end
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Devi effettuare l'accesso"
    end
  end
end
