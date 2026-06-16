class PasswordResetMailer < ApplicationMailer
  default from: "developers@dayspringlabs.com"

  def reset_email
    @user = params[:user]
    token = @user.signed_id(expires_in: 15.minutes, purpose: :password_reset)
    
    host = ENV.fetch("HOST", "dayspringfantasy.onrender.com")
    protocol = Rails.env.production? ? "https" : "http"
    
    @url = edit_password_reset_url(token: token, host: host, protocol: protocol)

    mail(to: @user.email, subject: "Password Reset Request")
  end

  def password_generated_email
    @user = params[:user]
    @password = params[:password]
    mail(to: @user.email, subject: "Your New Password for Dayspring Fantasy")
  end
end
