class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    return if user_signed_in?

    redirect_to new_session_path, alert: "Please log in to continue."
  end

  def authenticate_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "Admin access only."
  end
end
