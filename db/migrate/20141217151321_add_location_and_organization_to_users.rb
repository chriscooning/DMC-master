class AddLocationAndOrganizationToUsers < ActiveRecord::Migration
  def up
    add_column :users, :location, :string
    add_column :users, :organization, :string
  end

  def down
    remove_column :users, :location
    remove_column :users, :organization
  end
end
