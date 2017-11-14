require 'spec_helper'

describe Assets::ReportResource do
  let(:account) { create(:account_with_permissions) }
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let(:user)    { create(:user).tap{|new_user| account.users << new_user }}

  context "analytics" do
    it "available for account owner" do
      expect {
        Assets::ReportResource.new(as: owner, account: account).read_all
      }.not_to raise_error
    end

    it "available for user with 'view_analytics' permission" do
      user.permissions << Permission.where(account_id: account.id, action: 'view_analytics')

      expect {
        Assets::ReportResource.new(as: user, account: account).read_all
      }.not_to raise_error
    end

    it "can't be viewed by others" do
      expect {
        Assets::ReportResource.new(as: user, account: account).read_all
      }.to raise_error(Errors::AuthorizationRequired)
    end
  end
end
