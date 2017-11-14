class ChangeFoldersPositionDefault < ActiveRecord::Migration
  def change
    change_column :folders, :position, :integer, default: 0
  end
end
