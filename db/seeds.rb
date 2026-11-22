# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Persist Motor's resource schema so the AdminUser list and record detail views
# use the same fields and access rules as the Rails model.
admin_user_schema = Motor::BuildSchema::LoadFromRails.call.find do |schema|
  schema[:name] == "admin_user"
end

if admin_user_schema && !Motor::Resource.exists?(name: admin_user_schema[:name])
  Motor::Resources::PersistConfigs.call(
    Motor::Resource.new(name: admin_user_schema[:name], preferences: admin_user_schema)
  )
end

admin_user = AdminUser.find_or_initialize_by(email: "admin@example.com")
admin_password = ENV["ADMIN_USER_PASSWORD"].presence

if admin_user.new_record? && admin_password.blank?
  raise "Set ADMIN_USER_PASSWORD before creating the seeded administrator."
end

admin_user.assign_attributes(first_name: "Kevin", last_name: "Hachem")
admin_user.password = admin_password if admin_password.present?
admin_user.save! if admin_user.new_record? || admin_user.changed?
