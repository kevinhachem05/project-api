class Session < ApplicationRecord
  belongs_to :user

  enum :client_type, { mobile: "mobile", browser: "browser" }

  validates :token_digest, :csrf_token, :expires_at, :absolute_expires_at, :client_type, presence: true
  validates :token_digest, uniqueness: true
end
