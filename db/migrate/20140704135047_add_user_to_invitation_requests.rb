class AddUserToInvitationRequests < ActiveRecord::Migration
  def change
    add_column :invitation_requests, :user_id, :integer
  end
end
