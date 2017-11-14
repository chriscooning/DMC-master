class CreatePermissions < ActiveRecord::Migration
  def up
    add_column_if_not_exists :users, :role_id, :integer

    create_table :permissions, force: true do |t|
      t.references :account
      t.references :resource
      t.string     :resource_type
      t.string     :action, limit: 50
      t.datetime   :deleted_at
    end

    create_table :roles, force: true do |t|
      t.references :account
      t.string     :name
      t.string     :description
    end

    create_table :users_permissions, id: false, force: true do |t|
      t.references :user
      t.references :permission
    end

    create_table :roles_permissions, id: false, force: true do |t|
      t.references :role
      t.references :permission
    end

    create_default_permissions_for(Account.all)
    create_default_permissions_for(Gallery.all)
    create_default_permissions_for(Folder.all)
  end

  def down
    drop_table :permissions
    drop_table :roles
    drop_table :users_permissions
    drop_table :roles_permissions

    remove_column_if_exists :users, :role_id
  end

  private

  def add_column_if_not_exists(table_name, column_name, column_type, options = {})
    if !ActiveRecord::Base.connection.column_exists?(table_name, column_name)
      add_column table_name, column_name, column_type, options
    end
  end

  def remove_column_if_exists(table_name, column_name)
    if ActiveRecord::Base.connection.column_exists?(table_name, column_name)
      remove_column table_name, column_name
    end
  end

  def create_default_permissions_for(resource_scope)
    return if resource_scope.size == 0
    resource_sample = resource_scope
    return if !resource_sample.respond_to?(:create_permissions, true)

    resource_scope.each do |resource|
      resource.send(:create_permissions)
    end
  end
end
