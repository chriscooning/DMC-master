class AddProcessedFlagToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :processed, :boolean, default: true
  end
end
