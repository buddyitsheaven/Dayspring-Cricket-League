require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:valid_user)
  end

  test "user can reset password successfully" do
    # 1. User visits the login page
    get new_session_path
    assert_response :success
    assert_select "a", text: "Forgot Password?"

    # 2. User clicks Forgot Password and visits the reset request page
    get new_password_reset_path
    assert_response :success
    assert_select "form"

    # 3. User submits their email
    assert_enqueued_emails 1 do
      post password_resets_path, params: { email: @user.email }
    end
    assert_redirected_to new_session_path
    assert_equal "If an account with that email exists, we've sent a password reset link.", flash[:notice]

    # 4. User receives email with the reset link
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], mail.to
    assert_match /Generate my new password/, mail.body.encoded

    # Extract token from the email link
    url_match = mail.body.encoded.match(/password_resets\/([a-zA-Z0-9_\-\.]+)\/edit/)
    assert url_match, "Token not found in email body"
    token = url_match[1]

    # 5. User clicks the link in the email
    get edit_password_reset_path(token: token)
    assert_response :success
    assert_select "h1", text: "Generate Password"
    assert_select "form"

    # 6. User confirms password generation
    patch password_reset_path(token: token)
    assert_response :success
    assert_select "h1", text: "Reset Successful"
    assert_select ".auth-card", /Your new auto-generated password is:/

    # Extract the new password from the page text
    new_password_match = response.body.match(/<div[^>]*>\s*([a-f0-9]{12})\s*<\/div>/)
    assert new_password_match, "Auto-generated password not found in response"
    new_password = new_password_match[1].strip

    # 7. User can log in with the new auto-generated password
    post session_path, params: { email: @user.email, password: new_password }
    assert_redirected_to root_path
    assert_equal "Welcome back.", flash[:notice]
    
    # Assert old password no longer works
    post session_path, params: { email: @user.email, password: 'old_password' }
    assert_response :unprocessable_entity
    assert_equal "Invalid email or password.", flash[:alert]
  end
end
