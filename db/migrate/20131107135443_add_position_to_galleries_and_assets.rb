class AddPositionToGalleriesAndAssets < ActiveRecord::Migration
  def change
    add_column :galleries, :position, :integer, default: 0
    add_column :assets, :position, :integer, default: 0
  end
end
