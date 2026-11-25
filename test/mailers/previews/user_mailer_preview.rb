class UserMailerPreview < ActionMailer::Preview
  def email_verification
    user = User.first || raise("Create a user first to preview the verification email")

    UserMailer.with(
      user_id: user.id,
      encrypted_code: UserMailer.encrypt_verification_code("123456"),
      purpose: "sign_up"
    ).email_verification
  end
end
