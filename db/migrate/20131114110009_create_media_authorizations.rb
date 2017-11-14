class CreateMediaAuthorizations < ActiveRecord::Migration
  def change
    create_table :media_authorizations do |t|
      t.integer :media_user_id
      t.integer :target_id
      t.string :target_type
      t.integer :target_owner_id
      t.string  :status
      t.timestamps
    end

    add_index :media_authorizations, :media_user_id
    add_index :media_authorizations, :target_owner_id
    add_index :media_authorizations, [:target_id, :target_type]
  end
end
