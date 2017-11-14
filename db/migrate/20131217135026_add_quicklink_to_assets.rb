class AddQuicklinkToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :quicklink_hash, :string
    add_column :assets, :quicklink_url, :string
    add_column :assets, :quicklink_valid_to, :datetime
    add_column :assets, :quicklink_downloadable, :boolean, default: false

    add_index :assets, :quicklink_hash
  end
end
