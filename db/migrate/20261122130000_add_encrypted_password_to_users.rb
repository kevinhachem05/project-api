# frozen_string_literal: true

class AddEncryptedPasswordToUsers < ActiveRecord::Migration[8.1]
  def up
    return if column_exists?(:users, :encrypted_password)

    add_column :users, :encrypted_password, :string, null: false, default: ""
  end

  def down
    remove_column :users, :encrypted_password if column_exists?(:users, :encrypted_password)
  end
end
