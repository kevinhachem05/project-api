class Session < ApplicationRecord
  IDLE_TIMEOUT = 30.minutes
  ABSOLUTE_LIFETIME = 30.days

  belongs_to :user

  enum :client_type, { mobile: "mobile", browser: "browser" }

  validates :token_digest, :csrf_token, :expires_at, :absolute_expires_at, :client_type, presence: true
  validates :token_digest, uniqueness: true

  def self.issue_for!(user:, client_type:, ip_address:)
    now = Time.current
    raw_token = SecureRandom.urlsafe_base64(32)
    csrf_token = SecureRandom.urlsafe_base64(32)
    absolute_expires_at = now + ABSOLUTE_LIFETIME

    session = user.sessions.create!(
      token_digest: Digest::SHA256.hexdigest(raw_token),
      csrf_token: csrf_token,
      expires_at: [ now + IDLE_TIMEOUT, absolute_expires_at ].min,
      absolute_expires_at: absolute_expires_at,
      last_active_at: now,
      ip_address: ip_address,
      client_type: client_type
    )

    [ session, raw_token ]
  end

  def expired?(at: Time.current)
    expires_at <= at || absolute_expires_at <= at
  end

  def revoked?
    revoked_at.present?
  end

  def refresh_activity!
    now = Time.current
    update_columns(
      last_active_at: now,
      expires_at: [ now + IDLE_TIMEOUT, absolute_expires_at ].min,
      updated_at: now
    )
  end
end
