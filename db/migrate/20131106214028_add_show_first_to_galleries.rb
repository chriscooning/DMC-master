class AddShowFirstToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :show_first, :boolean, default: false
  end
end
