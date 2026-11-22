class User < ApplicationRecord
  devise :database_authenticatable

  has_many :sessions, dependent: :destroy

  enum :status, { active: "active", suspended: "suspended", deactivated: "deactivated" }, default: :active

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true

  def active_for_authentication?
    super && active? && platform_admin?
  end
end
