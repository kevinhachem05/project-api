# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user_schema = Motor::BuildSchema::LoadFromRails.call.find do |schema|
  schema[:name] == "user"
end

Motor::Resource.where(name: "admin_user").delete_all

if user_schema && !Motor::Resource.exists?(name: user_schema[:name])
  Motor::Resources::PersistConfigs.call(
    Motor::Resource.new(name: user_schema[:name], preferences: user_schema)
  )
end

admin_email = ENV.fetch("ADMIN_USER_EMAIL", "admin@example.com").strip.downcase
admin = User.where("LOWER(email) = ?", admin_email).first || User.new(email: admin_email)
admin_password = ENV["ADMIN_USER_PASSWORD"].presence

if admin_password.blank? && (admin.new_record? || admin.encrypted_password.blank?)
  raise "Set ADMIN_USER_PASSWORD before creating or repairing the seeded platform administrator."
end

admin.assign_attributes(first_name: "Kevin", last_name: "Hachem", platform_admin: true, status: :active)
admin.password = admin_password if admin_password.present?
admin.save! if admin.new_record? || admin.changed?
