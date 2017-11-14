class CreateDownloadsTable < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.integer :subject_id
      t.string  :subject_type
      t.integer :asset_id
      t.integer :owner_id
      t.timestamps
    end
  end
end