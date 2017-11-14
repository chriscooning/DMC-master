class AddPasswordExpireAtToAdminUsers < ActiveRecord::Migration
  def up
    add_column :admin_users, :password_expire_at, :datetime

    AdminUser.all.each do |admin_user|
      admin_user.update_password_expiration_date!
    end
  end

  def down
    remove_column :admin_users, :password_expire_at, :datetime
  end
end
