class RemoveUsersAvatar < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove   "avatar_file_name"
      t.remove   "avatar_content_type"
      t.remove   "avatar_file_size"
      t.remove   "avatar_updated_at"
    end
  end
end
