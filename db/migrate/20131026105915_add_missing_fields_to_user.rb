class AddMissingFieldsToUser < ActiveRecord::Migration
  def change
    add_attachment :users, :logo
    add_column :users, :logo_text, :string
    add_column :users, :logo_url, :string
    add_column :users, :restrictions_message, :text
    add_column :users, :help_message, :text
  end
end
