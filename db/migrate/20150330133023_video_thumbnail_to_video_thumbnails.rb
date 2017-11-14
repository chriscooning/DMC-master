class VideoThumbnailToVideoThumbnails < ActiveRecord::Migration
  def up
    add_column :assets, :video_thumbnails, :text
    Asset.all.each do |asset|
    	if asset.video_thumbnail.present?
      	asset.update_column(:video_thumbnails, { 'jpg_550x' => asset.video_thumbnail })
    	end
    end
  end

  def down
  	remove_column :assets, :video_thumbnails
  end
end
