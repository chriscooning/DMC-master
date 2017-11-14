require 'spec_helper'

describe PermissionsAssigner do
  it "should do nothing for nil" do
    account = create(:account)
    user = create(:user)
    subject = PermissionsAssigner.new(account: account, resource: user)
    subject.process(nil, nil)

    expect(User.find(user.id).roles).to be_empty
    expect(User.find(user.id).permissions).to be_empty
  end

  describe "#roles" do
    let(:account)         { create(:account_with_roles) }
    let(:another_account) { create(:account_with_roles) }

    it "should assign roles only for given account" do
      user = create(:user)
      account.users << user

      expect(account.roles).not_to be_empty 
      expect(another_account.roles).not_to be_empty 

      subject = PermissionsAssigner.new(account: account, resource: user)

      subject.process(another_account.roles.map(&:id), nil)
      expect(user.roles).to be_empty

      subject.process(Role.all.map(&:id), nil)
      expect(user.role_ids).to eq(account.roles.map(&:id))
    end

    it "should not change roles from other account" do
      user = create(:user)
      user.accounts << [ account, another_account ]
      user.roles = [account.roles, another_account.roles].flatten

      expect(user.roles).not_to be_empty 

      subject = PermissionsAssigner.new(account: account, resource: user)
      subject.process([], nil)

      expect(user.role_ids).to eq(another_account.roles.map(&:id))
    end
  end

  describe "#permissions" do
    let(:account)         { create(:account_with_permissions) }
    let(:another_account) { create(:account_with_permissions) }

    it "should assign permissions only for given account" do
      user = create(:user)
      account.users << user

      subject = PermissionsAssigner.new(account: account, resource: user)

      subject.process(nil, another_account.permissions.map(&:id))
      expect(user.permissions).to be_empty

      subject.process(nil, Permission.all.map(&:id))
      expect(user.permission_ids).to eq(account.permission_ids)
    end

    it "should not change permissions from other account" do
      user = create(:user)
      user.accounts << [ account, another_account ]
      user.permissions = [
        account.permissions,
        another_account.permissions
      ].flatten

      expect(user.permissions).not_to be_empty 

      subject = PermissionsAssigner.new(account: account, resource: user)
      subject.process([], nil)

      expect(user.role_ids).to eq(another_account.roles.map(&:id))
    end
  end
end
