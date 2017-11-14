class StoreAssetsSortOrderInFolders < ActiveRecord::Migration
  def change
    add_column :folders, :assets_sort_order, :string
  end
end
