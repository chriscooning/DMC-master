class AddTagsCachingToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :cached_tag_list, :text
  end
end
