class AddAlternativeVideoThumbnailToAssets < ActiveRecord::Migration
  def change
    change_table :assets do |t|
      t.attachment :alternative_video_thumbnail
    end
  end
end