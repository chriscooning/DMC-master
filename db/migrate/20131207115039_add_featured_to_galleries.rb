class AddFeaturedToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :featured, :boolean, default: false
    add_attachment :galleries, :featured_image
  end
end
