module Sessions
  class RequestSignIn
    def self.call(email:, client_type:)
      normalized_email = email.to_s.strip.downcase
      user = User.where("LOWER(email) = ?", normalized_email).first

      return unless user&.active? && user.email_verified_at.present?

      EmailVerifications::Issue.call(user:, purpose: :sign_in, client_type:)
    end
  end
end
