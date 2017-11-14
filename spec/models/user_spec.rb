require 'spec_helper'

describe User do
  it { should validate_presence_of :full_name }
  it { should validate_presence_of :email }

  context "#account_owner?" do
    let(:user) { create(:user_without_account) }
    let(:account) { create(:account) }

    it "true for account owner" do
      account.owner = user
      expect(
        user.account_owner?(account)
      ).to be_true
    end

    it "false for sub-account user" do
      user.accounts << account
      expect(
        user.account_owner?(account)
      ).to be_false
    end

    it "true if user not assigned to any account" do
      expect(
        user.account_owner?(account)
      ).to be_false
    end
  end

  context "#primary account" do
    let(:user)    { create(:user) }
    let(:account) { create(:account) }

    it "returns primary account" do
      user.primary_account = account
      expect(User.find(user.id).primary_account.id).to eq(account.id)
    end

    it "returns any account if there are no primary accounts" do
      user.accounts.delete
      user.accounts << account
      expect(User.find(user.id).primary_account.id).to eq(account.id)
    end
  end
end
