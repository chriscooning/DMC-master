require 'spec_helper'

# sub users 
describe SubUsers::InvitationResource do
  let(:account) { create(:account_with_permissions).tap{|acc| acc.owner = create(:user) }}
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let(:user)    { create(:user) }
  let(:gallery) { create(:gallery, account_id: account.id) }
  let(:invite)  { create(:invitation_request, gallery_id: gallery.id) }

  context "#build" do
    it 'build new user' do
      subject = SubUsers::InvitationResource.new(as: owner, account: account, params: {})
      result = subject.build.result.resource
      expect(result).to be_kind_of(User)
    end

    it 'build new user with values from invitation' do
      params = { invitation_request: invite.id }
      subject = SubUsers::InvitationResource.new(as: owner, account: account, params: params)
      result = subject.build.result.resource

      expect(result).to be_kind_of(User)
      expect(result.email).to eq(invite.email)
      expect(result.permission_ids).not_to be_blank
    end
  end

  context "#create" do
    it 'add existing user to account user' do
      params = { user: { email: user.email }}
      subject = SubUsers::InvitationResource.new(as: owner, account: account, params: params)
      subject.create

      result = AccountUser.where(account_id: account.id, user_id: user.id).first

      expect(result).not_to be_blank
      expect(result.primary).to be_false
      expect(result.invited).to  be_true
      expect(result.owner).to   be_false
    end
  end
end
