class AddLogoHeightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :logo_height, :integer
  end
end
