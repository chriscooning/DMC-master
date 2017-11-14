class CreateInvitationRequests < ActiveRecord::Migration
  def change
    create_table :invitation_requests do |t|
      t.integer :gallery_id
      t.string  :email
      t.string  :invitation_hash
      t.timestamps
    end
  end
end
