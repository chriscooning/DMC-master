class AddEnableInvitationCredentialsToGalleries < ActiveRecord::Migration
  def change
    add_column :galleries, :enable_invitation_credentials, :boolean, default: false
  end
end
