class AddLandingTitleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :landing_title, :string
  end
end
