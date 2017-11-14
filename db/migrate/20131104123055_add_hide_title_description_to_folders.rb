class AddHideTitleDescriptionToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :hide_title, :boolean, default: false
    add_column :folders, :hide_description, :boolean, default: false
  end
end
