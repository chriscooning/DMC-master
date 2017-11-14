class CreateMenuLinks < ActiveRecord::Migration
  def change
    create_table :menu_links do |t|
      t.integer :gallery_id
      t.string  :link
      t.string  :content
      t.integer :position, default: 0
    end

    add_index :menu_links, :gallery_id
  end
end
