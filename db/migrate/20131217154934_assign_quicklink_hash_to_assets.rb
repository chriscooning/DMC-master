class AssignQuicklinkHashToAssets < ActiveRecord::Migration
  def change
    Asset.find_each do |asset|
      asset.update_column :quicklink_hash, SecureRandom.hex
    end
  end
end
