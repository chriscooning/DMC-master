class MoveSubdomainProductionToAccount < ActiveRecord::Migration
  def up
    add_column_if_not_exists :accounts, :enable_subdomain_password, :boolean, default: false
    add_column_if_not_exists :accounts, :encrypted_subdomain_password, :string, default: false

    # update references in subdomain_authorized_keys
    SubdomainAuthorizedKey.all.each do |auth_key|
      if auth_key.account_id.blank? && auth_key.user.primary_account.present?
        auth_key.update_column(:account_id, auth_key.user.primary_account.id)
      end
    end
  end

  def down
    remove_column_if_exists :accounts, :enable_subdomain_password, :boolean, default: false
    remove_column_if_exists :accounts, :encrypted_subdomain_password, :string, default: false
  end

  private

    def add_column_if_not_exists(table_name, field_name, field_type, options = {})
      if !ActiveRecord::Base.connection.column_exists?(table_name, field_name)
        add_column table_name, field_name, field_type, options
      end
    end

    def remove_column_if_exists(table_name, field_name)
      if ActiveRecord::Base.connection.column_exists?(table_name, field_name)
        remove_column table_name, field_name
      end
    end
end
