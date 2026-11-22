class AdminUser < ApplicationRecord
  devise :database_authenticatable, :validatable

  validates :first_name, :last_name, presence: true
end
