class AddVideoThumbnailToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :video_thumbnail, :text
  end
end
