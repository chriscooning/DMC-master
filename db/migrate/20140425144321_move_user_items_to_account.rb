class MoveUserItemsToAccount < ActiveRecord::Migration
  def up
    move_items_to_accounts_table(Announcement)
    move_items_to_accounts_table(Asset)
    move_items_to_accounts_table(Gallery)

    change_items_reference_to_account(MediaAuthorization, :target_owner_id)
    change_items_reference_to_account(Event, :target_owner_id)
  end

  def down
    move_items_to_users_table(Announcement)
    move_items_to_users_table(Asset)
    move_items_to_users_table(Gallery)

    change_items_reference_to_user(MediaAuthorization, :target_owner_id)
    change_items_reference_to_user(Event, :target_owner_id)
  end

  private

  def move_items_to_accounts_table(model_class)
    table_name = model_class.table_name

    unless ActiveRecord::Base.connection.column_exists?(table_name, :account_id)
      add_column table_name, :account_id, :integer
      model_class.reset_column_information
    end

    if ActiveRecord::Base.connection.column_exists?(table_name, :user_id)
      Account.all.each do |account|
        model_class.update_all({ account_id: account.id }, { user_id: account.owner_id })
      end

      remove_column table_name, :user_id
    end
  end

  def move_items_to_users_table(model_class)
    table_name = model_class.table_name

    unless ActiveRecord::Base.connection.column_exists?(table_name, :user_id)
      add_column table_name, :user_id, :integer
      model_class.reset_column_information
    end

    if ActiveRecord::Base.connection.column_exists?(table_name, :account_id)
      Account.all.each do |account|
        model_class.update_all({ user_id: account.owner_id }, { account_id: account.id })
      end

      remove_column table_name, :account_id
    end
  end

  def change_items_reference_to_account(model_class, field)
    model_class.all.each do |model|
      user_id = model.send(field)
      account_id = User.find_by_id(user_id).try(:account_id)
      model.update_attribute(field, account_id)
    end
  end

  def change_items_reference_to_user(model_class, field)
    model_class.all.each do |model|
      account_id = model.send(field)
      user_id = Account.find_by_id(user_id).try(:owner_id)
      model.update_attribute(field, user_id)
    end
  end
end
