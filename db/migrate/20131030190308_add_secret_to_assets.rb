class AddSecretToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :secret, :string

    add_index :assets, :secret
  end
end
