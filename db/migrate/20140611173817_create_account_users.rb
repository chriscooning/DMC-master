class CreateAccountUsers < ActiveRecord::Migration
  def up
    create_table :account_users, force: true do |t|
      t.references :account
      t.references :user
      t.boolean :primary, default: false
      t.boolean :owner,   default: false
      t.boolean :invited, default: false
    end

    create_table :user_roles, force: true do |t|
      t.references :user
      t.references :role
    end

    update_user_to_account_relation
    update_users_roles_relation
  end

  def down
    if ActiveRecord::Base.connection.table_exists?(:account_users)
      drop_table :account_users
    end
    if ActiveRecord::Base.connection.table_exists?(:user_roles)
      drop_table :user_roles
    end
  end

  private

  def update_user_to_account_relation
    Account.all.each do |account|
      account.users = User.where(account_id: account.id)

      if account.owner_id && (owner = User.find(account.owner_id)).present?
        connection = AccountUser.where(account_id: account.id, user_id: owner.id).first_or_initialize
        connection.owner = true
        connection.save
      end
    end
  end
  
  def update_users_roles_relation
    User.all.each do |user|
      if user.role_id && (role = Role.find(user.role_id)).present?
        user.roles = Array.wrap(role)
        user.save
      end
    end
  end
end
