# frozen_string_literal: true

class CreateUsersAndSessions < ActiveRecord::Migration[8.1]
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""
      t.datetime :email_verified_at
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.boolean :platform_admin, null: false, default: false
      t.string :status, null: false, default: "active"
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_check_constraint :users, "status IN ('active', 'suspended', 'deactivated')", name: "users_status_check"

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.string :csrf_token, null: false
      t.datetime :expires_at, null: false
      t.datetime :absolute_expires_at, null: false
      t.datetime :last_active_at
      t.datetime :revoked_at
      t.string :ip_address
      t.string :client_type, null: false
      t.timestamps null: false
    end

    add_index :sessions, :token_digest, unique: true
    add_check_constraint :sessions, "client_type IN ('mobile', 'browser')", name: "sessions_client_type_check"

    migrate_admin_users
    drop_table :admin_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "User accounts and session data cannot be restored to admin_users."
  end

  private

  def migrate_admin_users
    return unless table_exists?(:admin_users)

    execute <<~SQL.squish
      INSERT INTO users (email, encrypted_password, first_name, last_name, platform_admin, status, created_at, updated_at)
      SELECT email, encrypted_password, first_name, last_name, TRUE, 'active', created_at, updated_at
      FROM admin_users
      ON CONFLICT (email) DO UPDATE
      SET platform_admin = TRUE,
          encrypted_password = EXCLUDED.encrypted_password,
          first_name = EXCLUDED.first_name,
          last_name = EXCLUDED.last_name
    SQL
  end
end
