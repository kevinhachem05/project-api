class User < ApplicationRecord
  devise :database_authenticatable

  has_many :sessions, dependent: :destroy
  has_many :email_verifications, dependent: :destroy

  enum :status, { active: "active", suspended: "suspended", deactivated: "deactivated" }, default: :active

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :first_name, :last_name, presence: true

  before_validation :normalize_email

  def active_for_authentication?
    super && active? && platform_admin?
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
