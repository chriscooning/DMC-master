class AddDefaultPerPageToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :default_per_page, :integer, default: 16
  end
end
