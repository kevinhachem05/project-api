class UserMailer < ApplicationMailer
  default from: -> { ENV.fetch("MAILER_FROM", "noreply@example.com") }

  def self.encrypt_verification_code(code)
    verification_code_encryptor.encrypt_and_sign(code)
  end

  def email_verification
    @user = User.find(params[:user_id])
    @code = self.class.verification_code_encryptor.decrypt_and_verify(params[:encrypted_code])
    @purpose = params[:purpose].to_s

    mail(to: @user.email, subject: "Verify your email address")
  end

  def self.verification_code_encryptor
    key = Rails.application.key_generator.generate_key("email_verification_mailer", ActiveSupport::MessageEncryptor.key_len)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
