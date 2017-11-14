class AddCopyrightsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :copyrights, :string
  end
end
