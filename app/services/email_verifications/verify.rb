module EmailVerifications
  class Verify
    class InvalidCode < StandardError; end

    def self.call(public_id:, code:, ip_address:)
      verification = EmailVerification.find_by(public_id:)
      raise InvalidCode unless verification

      session_and_token = nil
      valid = verification.with_lock do
        next false unless verification.pending?

        unless verification.matches_code?(code)
          verification.attempts_count += 1
          verification.consumed_at = Time.current if verification.exhausted?
          verification.save!
          next false
        end

        user = verification.user
        next false unless user.active?
        if verification.sign_up?
          user.update!(email_verified_at: Time.current)
        else
          next false unless user.email_verified_at.present?
        end

        verification.update!(consumed_at: Time.current)
        session_and_token = Session.issue_for!(
          user:,
          client_type: verification.client_type,
          ip_address:
        )
        true
      end

      raise InvalidCode unless valid

      [ verification.user, *session_and_token ]
    end
  end
end
