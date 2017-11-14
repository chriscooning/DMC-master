class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :authentication_token_expires_at, :datetime

    add_index :users, :authentication_token
  end
end
