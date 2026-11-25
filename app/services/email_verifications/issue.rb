module EmailVerifications
  class Issue
    class DeliveryFailed < StandardError; end

    DEVELOPMENT_CODE = "000000"

    def self.call(user:, purpose:, client_type:)
      new(user:, purpose:, client_type:).call
    end

    def initialize(user:, purpose:, client_type:)
      @user = user
      @purpose = purpose
      @client_type = client_type
    end

    def call
      now = Time.current
      latest = user.email_verifications.where(purpose:).order(created_at: :desc).first

      if latest&.pending? && latest.created_at > now - EmailVerification::RESEND_INTERVAL
        return latest
      end

      user.email_verifications.pending.where(purpose:).update_all(consumed_at: now, updated_at: now)
      code = verification_code
      public_id = SecureRandom.uuid
      verification = user.email_verifications.create!(
        public_id:,
        purpose:,
        client_type:,
        code_digest: EmailVerification.digest_code(public_id, code),
        expires_at: now + EmailVerification::CODE_LIFETIME
      )

      deliver_code(code, verification)

      verification
    end

    private

    def verification_code
      return DEVELOPMENT_CODE if Rails.env.development? || Rails.env.test?

      format("%06d", SecureRandom.random_number(1_000_000))
    end

    def deliver_code(code, verification)
      return if Rails.env.development? || Rails.env.test?

      encrypted_code = UserMailer.encrypt_verification_code(code)
      UserMailer.with(user_id: user.id, encrypted_code:, purpose:).email_verification.deliver_later
    rescue StandardError => error
      verification.destroy!
      raise DeliveryFailed, "Verification email could not be delivered.", cause: error
    end

    attr_reader :user, :purpose, :client_type
  end
end
