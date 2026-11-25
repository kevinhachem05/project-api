# frozen_string_literal: true

class CreateEmailVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :email_verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.uuid :public_id, null: false
      t.string :purpose, null: false
      t.string :client_type, null: false
      t.string :code_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.integer :attempts_count, null: false, default: 0
      t.timestamps null: false
    end

    add_index :email_verifications, :public_id, unique: true
    add_index :email_verifications, %i[user_id purpose created_at], name: "index_email_verifications_for_resend"
    add_check_constraint :email_verifications,
                         "purpose IN ('sign_up', 'sign_in')",
                         name: "email_verifications_purpose_check"
    add_check_constraint :email_verifications,
                         "client_type IN ('mobile', 'browser')",
                         name: "email_verifications_client_type_check"
    add_check_constraint :email_verifications,
                         "attempts_count >= 0",
                         name: "email_verifications_attempts_count_check"
  end
end
