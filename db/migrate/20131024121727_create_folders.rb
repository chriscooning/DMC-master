class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.integer :gallery_id
      t.string :name
      t.boolean :hide_folder, default: false
      t.boolean :enable_credentials, default: false
      t.integer :position
      t.timestamps
    end

    add_index :folders, [:gallery_id, :hide_folder]
  end
end
