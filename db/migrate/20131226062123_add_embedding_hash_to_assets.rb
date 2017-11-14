class AddEmbeddingHashToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :embedding_hash, :string

    add_index :assets, :embedding_hash
  end
end
