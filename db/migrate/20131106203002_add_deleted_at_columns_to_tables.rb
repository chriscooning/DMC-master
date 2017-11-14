class AddDeletedAtColumnsToTables < ActiveRecord::Migration
  def change
    add_column :galleries, :deleted_at, :datetime
    add_column :folders, :deleted_at, :datetime
    add_column :assets, :deleted_at, :datetime
  end
end
