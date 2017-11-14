class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :subject_id
      t.string  :subject_type
      t.string  :name
      t.integer :target_id
      t.string  :target_type
      t.integer :target_owner_id
      t.timestamps
    end
  end
end
