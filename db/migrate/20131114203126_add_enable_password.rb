class AddEnablePassword < ActiveRecord::Migration
  def change
    add_column :folders, :enable_password, :boolean, default: false
    add_column :galleries, :enable_password, :boolean, default: false
  end
end
