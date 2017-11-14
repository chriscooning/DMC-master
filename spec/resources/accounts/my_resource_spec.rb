require 'spec_helper'

# sub users 
describe Accounts::MyResource do
  let(:account) { create(:account_with_permissions) }
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let(:user)    { create(:user).tap{|new_user| account.users << new_user }}

  context "#view" do
    it "available for account owner" do
      expect {
        Accounts::MyResource.new(as: owner, account: account).edit
      }.not_to raise_error
    end

    it "available for user with 'read account' permission" do
      user.permissions << Permission.where(resource_id: account.id, resource_type: 'Account', action: 'read')

      expect {
        Accounts::MyResource.new(as: user, account: account).edit
      }.not_to raise_error
    end

    it "can't be viewed by others" do
      expect {
        Accounts::MyResource.new(as: user, account: account).edit
      }.to raise_error(Errors::AuthorizationRequired)
    end
  end

  context "#update" do
    let(:params) { { account: { restriction_message: 'some message' }}}
    let(:resource_params) { { params: params, account: account }}

    it "available for account owner" do
      expect {
        Accounts::MyResource.new(resource_params.merge(as: owner)).update
      }.not_to raise_error
    end

    it "available for user with 'read account' permission" do
      user.permissions << Permission.where(resource_id: account.id, resource_type: 'Account', action: 'edit')

      expect {
        Accounts::MyResource.new(resource_params.merge(as: user)).update
      }.not_to raise_error
    end

    it "can't be viewed by others" do
      expect {
        Accounts::MyResource.new(resource_params.merge(as: user)).update
      }.to raise_error(Errors::AuthorizationRequired)
    end
  end
end
