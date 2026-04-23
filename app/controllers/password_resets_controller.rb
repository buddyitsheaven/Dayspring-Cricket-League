class PasswordResetsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user
      PasswordResetMailer.with(user: user).reset_email.deliver_later
    end

    redirect_to new_session_path, notice: "If an account with that email exists, we've sent a password reset link."
  end

  def edit
    @user = User.find_signed(params[:token], purpose: :password_reset)
    redirect_to new_session_path, alert: "Password reset link is invalid or has expired." unless @user
  end

  def update
    @user = User.find_signed(params[:token], purpose: :password_reset)

    if @user
      @new_password = SecureRandom.hex(6)
      @user.update!(password: @new_password, password_confirmation: @new_password)
      render :success
    else
      redirect_to new_session_path, alert: "Password reset link is invalid or has expired."
    end
  end
end
