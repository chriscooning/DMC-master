class ReprocessImagesThumbnails < ActiveRecord::Migration
  def change
  	Asset.all.each do |asset|
  		asset.file.reprocess!(:large) if asset.image?
  		asset.custom_thumbnail.reprocess!(:large) if asset.custom_thumbnail.present?
		end
  end
end
