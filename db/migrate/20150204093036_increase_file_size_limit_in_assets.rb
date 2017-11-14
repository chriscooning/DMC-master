class IncreaseFileSizeLimitInAssets < ActiveRecord::Migration
  def change
    change_column :assets, :file_file_size, :bigint
  end
end
