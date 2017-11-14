class AddPasswordProtectionToGallery < ActiveRecord::Migration
  def change
    add_column :galleries, :encrypted_password, :string
    add_column :galleries, :enable_credentials, :boolean, default: false

    create_table :gallery_authorized_keys do |t|
      t.integer :gallery_id
      t.string  :key
      t.timestamps
    end
  end
end
