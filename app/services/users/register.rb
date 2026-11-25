module Users
  class Register
    def self.call(attributes:, client_type:)
      user = User.new(attributes)
      user.status = :active
      user.platform_admin = false
      user.email_verified_at = nil
      user.save!

      verification = EmailVerifications::Issue.call(
        user:,
        purpose: :sign_up,
        client_type:
      )

      [ user, verification ]
    end
  end
end
