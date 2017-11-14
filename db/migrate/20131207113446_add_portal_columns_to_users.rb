class AddPortalColumnsToUsers < ActiveRecord::Migration
  def change
    add_attachment :users, :portal_header_image
    add_column :users, :welcome_message, :text
  end
end
