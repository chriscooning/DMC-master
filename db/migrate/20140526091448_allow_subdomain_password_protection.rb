class AllowSubdomainPasswordProtection < ActiveRecord::Migration
  def up
    add_columns_for(:accounts) if ActiveRecord::Base.connection.table_exists?(:accounts)
    add_columns_for(:users) if ActiveRecord::Base.connection.table_exists?(:users)

    create_table :subdomain_authorized_keys, force: true do |t|
      t.references :account
      t.references :user
      t.string     :key
      t.timestamps
    end
  end

  def down
    remove_columns_from(:accounts) if ActiveRecord::Base.connection.table_exists?(:accounts)
    remove_columns_from(:users) if ActiveRecord::Base.connection.table_exists?(:users)

    if ActiveRecord::Base.connection.table_exists?(:subdomain_authorized_keys)
      drop_table :subdomain_authorized_keys
    end
  end

  private

  def add_columns_for(table_name)
    if !ActiveRecord::Base.connection.column_exists?(table_name, :enable_subdomain_password)
      add_column table_name, :enable_subdomain_password, :boolean, default: false
    end
    if !ActiveRecord::Base.connection.column_exists?(table_name, :encrypted_subdomain_password)
      add_column table_name, :encrypted_subdomain_password, :string, default: false
    end
  end

  def remove_columns_from(table_name)
    if ActiveRecord::Base.connection.column_exists?(table_name, :enable_subdomain_password)
      remove_column table_name, :enable_subdomain_password
    end
    if ActiveRecord::Base.connection.column_exists?(table_name, :encrypted_subdomain_password)
      remove_column table_name, :encrypted_subdomain_password
    end
  end
end
