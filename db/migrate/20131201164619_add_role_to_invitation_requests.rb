class AddRoleToInvitationRequests < ActiveRecord::Migration
  def change
    add_column :invitation_requests, :role, :string
  end
end
