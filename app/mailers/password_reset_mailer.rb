class PasswordResetMailer < ApplicationMailer
  def reset_email
    @user = params[:user]
    token = @user.signed_id(expires_in: 15.minutes, purpose: :password_reset)
    
    # In production, use the Render host. Otherwise use a generic fallback.
    host = ENV.fetch("HOST", "dayspringfantasy.onrender.com")
    protocol = Rails.env.production? ? "https" : "http"
    
    @url = edit_password_reset_url(token: token, host: host, protocol: protocol)

    mail(to: @user.email, subject: "Password Reset Request")
  end
end
