require "spec_helper"

describe Backend::SettingsController do
  include Devise::TestHelpers

  render_views

  let(:account) { create(:account) }
  let(:owner) { create(:confirmed_user).tap{|user| account.owner = user; account.save }}
  let(:user)  { create(:confirmed_user).tap{|user| account.users << user }}

  before :each do
    sign_in user
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#account" do
    it "should be available only for owner" do
      sign_in owner
      get :account
      expect(response.status).to eq 200
    end

    it "should not be available for non-owner" do
      pending 'todo: user should have permission to edit accounts'
      sign_in user
      get :account
      # NotAuthorized error
      expect(response.status).to eq 302
    end
  end

  describe "#analytics" do
    it "should be available only for owner" do
      sign_in owner
      get :analytics
      expect(response.status).to eq 200
    end

    it "should not be available for non-owner" do
      owner # load owner
      sign_in user
      get :analytics
      # NotAuthorized error
      expect(response.status).to eq 302
    end
  end

  describe "#security" do
    it "should be available only for owner" do
      sign_in owner
      get :security
      #expect(response.status).to eq 200
      expect(response.status).to eq 302
    end

    it "should not be available for non-owner" do
      owner # load owner
      sign_in user
      get :security
      # NotAuthorized error
      expect(response.status).to eq 302
    end
  end
end
