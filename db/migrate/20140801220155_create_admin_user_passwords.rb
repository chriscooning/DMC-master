class CreateAdminUserPasswords < ActiveRecord::Migration
  def up
    create_table :admin_user_passwords, force: true do |t|
      t.references :admin_user
      t.string :encrypted_password

      t.timestamps
    end

    AdminUser.all.each do |admin_user|
      admin_user.store_password
    end
  end

  def down
    drop_table :admin_user_passwords
  end
end
