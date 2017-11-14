require 'spec_helper'

describe EventsGrapher do
  let(:account) { create(:account_with_permissions) }
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let(:user)    { create(:user).tap{|new_user| account.users << new_user }}
  let(:gallery) { create(:gallery, account: account) }
  let(:folder)  { create(:folder, gallery: gallery) }
  let(:asset)   { create(:asset, folder: folder, account: account) }

  context "read_all" do
    it "available for account owner" do
      expect {
        EventsGrapher.new(as: owner, account: account).read_all
      }.not_to raise_error
    end

    it "available for user with 'view_analytics' permission" do
      user.permissions << Permission.where(account_id: account.id, action: 'view_analytics')

      expect {
        EventsGrapher.new(as: user, account: account).read_all
      }.not_to raise_error
    end

    it "can't be viewed by others" do
      expect {
        EventsGrapher.new(as: user, account: account).read_all
      }.to raise_error(Errors::AuthorizationRequired)
    end
  end

  context "read" do
    it "available for account owner" do
      expect {
        EventsGrapher.new(as: owner, account: account).read(id: asset.id)
      }.not_to raise_error
    end

    it "available for user with 'view_analytics' permission" do
      user.permissions << Permission.where(account_id: account.id, action: 'view_analytics')

      expect {
        EventsGrapher.new(as: user, account: account).read(id: asset.id)
      }.not_to raise_error
    end

    it "can't be viewed by others" do
      expect {
        EventsGrapher.new(as: user, account: account).read(id: asset.id)
      }.to raise_error(Errors::AuthorizationRequired)
    end
  end
end
