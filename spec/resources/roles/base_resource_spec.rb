require 'spec_helper'

# sub users 
describe Roles::BaseResource do

  context "auth" do
    let(:account) { create(:account_with_permissions).tap{|acc| acc.owner = create(:user) }}
    let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
    let(:user)    { create(:user).tap{|new_user| new_user.primary_account = account}}

    context "index" do
      it "available for account owner" do
        expect {
          Roles::BaseResource.new(as: owner, account: account).read_all
        }.not_to raise_error
      end

      it "available for user with 'view_analytics' permission" do
        user.permissions << Permission.where(account_id: account.id, action: 'view_subaccounts')

        expect {
          Roles::BaseResource.new(as: user, account: account).read_all
        }.not_to raise_error
      end

      it "can't be viewed by others" do
        expect {
          Roles::BaseResource.new(as: user, account: account).read_all
        }.to raise_error(Errors::AuthorizationRequired)
      end
    end

    context "edit" do
      it "available for account owner" do
        expect {
          Roles::BaseResource.new(as: owner, account: account).build
        }.not_to raise_error
      end

      it "available for user with 'view_analytics' permission" do
        user.permissions << Permission.where(account_id: account.id, action: 'edit_subaccounts')

        expect {
          Roles::BaseResource.new(as: user, account: account).build
        }.not_to raise_error
      end

      it "can't be viewed by others" do
        expect {
          Roles::BaseResource.new(as: user, account: account).build
        }.to raise_error(Errors::AuthorizationRequired)
      end
    end
  end
end
