class GenerateEmbeddingHashForAssets < ActiveRecord::Migration
  def change
    Asset.find_each do |asset|
      asset.embedding_hash ||= SecureRandom.hex
      asset.save
    end
  end
end
