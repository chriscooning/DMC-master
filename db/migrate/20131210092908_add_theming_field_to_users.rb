class AddThemingFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :theme, :text
  end
end
