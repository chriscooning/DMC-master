class CreateAuthorizedFolders < ActiveRecord::Migration
  def change
    create_table :folder_authorized_keys do |t|
      t.integer :folder_id
      t.string  :key
      t.timestamps
    end
  end
end
