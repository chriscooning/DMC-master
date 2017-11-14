class CreateGalleriesInvites < ActiveRecord::Migration
  def change
    create_table :gallery_members do |t|
      t.integer :user_id
      t.integer :gallery_id
      t.string  :role
      t.timestamps
    end
  end
end
