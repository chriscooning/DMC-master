class AddS3HashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :s3_hash, :string
  end
end
