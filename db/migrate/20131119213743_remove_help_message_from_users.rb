class RemoveHelpMessageFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :help_message
  end
end
