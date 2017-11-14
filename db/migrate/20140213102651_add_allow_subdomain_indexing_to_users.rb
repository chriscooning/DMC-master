class AddAllowSubdomainIndexingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allow_subdomain_indexing, :boolean, default: true
  end
end
