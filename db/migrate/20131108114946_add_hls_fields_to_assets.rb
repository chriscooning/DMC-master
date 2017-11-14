class AddHlsFieldsToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :m3u8_url, :string
  end
end
