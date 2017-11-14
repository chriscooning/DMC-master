class AddCustomThumbnail < ActiveRecord::Migration
  def change
    change_table :assets do |t|
      t.rename "alternative_video_thumbnail_file_name",     "custom_thumbnail_file_name"
      t.rename "alternative_video_thumbnail_content_type",  "custom_thumbnail_content_type"
      t.rename "alternative_video_thumbnail_file_size",     "custom_thumbnail_file_size"
      t.rename "alternative_video_thumbnail_updated_at",    "custom_thumbnail_updated_at"
    end
  end
end
