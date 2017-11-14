class AddAccountUsersCountToAccounts < ActiveRecord::Migration

  def self.up

    add_column :accounts, :account_users_count, :integer, :null => false, :default => 0

  end

  def self.down

    remove_column :accounts, :account_users_count

  end

end
