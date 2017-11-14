class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.integer :user_id
      t.string  :title
      t.text    :text
      t.timestamps
    end

    add_index :announcements, :user_id
  end
end
