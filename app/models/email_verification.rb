class EmailVerification < ApplicationRecord
  MAX_ATTEMPTS = 5
  CODE_LIFETIME = 5.minutes
  RESEND_INTERVAL = 1.minute

  belongs_to :user

  enum :purpose, { sign_up: "sign_up", sign_in: "sign_in" }
  enum :client_type, { mobile: "mobile", browser: "browser" }

  validates :public_id, :code_digest, :expires_at, :purpose, :client_type, presence: true
  validates :attempts_count, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(consumed_at: nil).where("expires_at > ?", Time.current) }

  def self.digest_code(public_id, code)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{public_id}:#{code}")
  end

  def matches_code?(code)
    candidate = self.class.digest_code(public_id, code.to_s)
    ActiveSupport::SecurityUtils.secure_compare(code_digest, candidate)
  end

  def expired?
    expires_at <= Time.current
  end

  def pending?
    consumed_at.nil? && !expired? && !exhausted?
  end

  def exhausted?
    attempts_count >= MAX_ATTEMPTS
  end
end
