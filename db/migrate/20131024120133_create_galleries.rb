class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.integer :user_id
      t.string :name
      t.attachment :logo
      t.string :logo_url
      t.text :gallery_message
      t.text :restrictions_message
      t.text :help_message
      t.boolean :visible, default: true
      t.timestamps
    end

    add_index :galleries, :user_id
  end
end
