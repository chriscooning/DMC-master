class AddFavoritesToAdminUser < ActiveRecord::Migration
  def up
    add_column :admin_users, :favorite_user_ids, :string, limit: 1024
    add_column :admin_users, :can_create_users, :boolean, default: false

    AdminUser.where(email: 'admin@digitalmediacenter.com').update_all(can_create_users: true)
  end

  def down
    remove_column :admin_users, :favorite_user_ids
    remove_column :admin_users, :can_create_users
  end
end
