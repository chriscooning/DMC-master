class AddEncryptedPasswordToFolder < ActiveRecord::Migration
  def change
    add_column :folders, :encrypted_password, :string
  end
end