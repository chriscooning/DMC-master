class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer :folder_id
      t.string :title
      t.text :description
      t.string :type
      t.attachment :file
      t.text :videos
      t.boolean :downloadable, default: true
      t.timestamps
    end
    
    add_index :assets, :folder_id
  end
end
