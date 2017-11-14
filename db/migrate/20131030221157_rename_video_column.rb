class RenameVideoColumn < ActiveRecord::Migration
  def change
    rename_column :assets, :videos, :video_urls
  end
end
