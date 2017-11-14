require "spec_helper"

describe Backend::GalleriesController do
  include Devise::TestHelpers
  render_views

  let(:account) { create(:account) }
  let(:another_account) { create(:account) }
  let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}
  let(:user)    { create(:confirmed_user).tap{|user| user.primary_account = another_account }}

  context "#portal" do
    it "page should be available for owner" do
      controller.stubs(:current_account).returns(account)
      sign_in owner
      get :portal
      expect(response.status).to eq 200
    end

    it "page should be available for invited user" do
      controller.stubs(:current_account).returns(account)
      user.accounts << account
      sign_in user
      get :portal
      expect(response.status).to eq 200
    end
  end

  context "#index" do
    before :each do
      2.times{ create(:gallery, account_id: account.id) }
    end

    it "page should be available for owner" do
      controller.stubs(:current_account).returns(account)
      sign_in owner
      get :index
      expect(response.status).to eq 200
    end

    it "page should be available for invited user" do
      controller.stubs(:current_account).returns(account)
      user.accounts << account
      sign_in user
      get :index
      expect(response.status).to eq 200
    end
  end

  context "#show" do
    let(:gallery) { create(:gallery, account_id: account.id) }

    it "page should be available for owner" do
      controller.stubs(:current_account).returns(account)
      sign_in owner
      get :show, id: gallery.id
      expect(response.status).to eq 200
    end

    it "page should be available for invited user" do
      controller.stubs(:current_account).returns(account)
      user.accounts << account
      sign_in user
      get :index, id: gallery.id
      expect(response.status).to eq 200
    end
  end

  context "#edit" do
    let(:gallery) { create(:gallery, account_id: account.id) }

    it "page should be available for owner" do
      controller.stubs(:current_account).returns(account)
      sign_in owner
      get :edit, id: gallery.id
      expect(response.status).to eq 200
    end

    it "page should be available for invited user" do
      controller.stubs(:current_account).returns(account)
      user.accounts << account
      sign_in user
      get :edit, id: gallery.id
      expect(response.status).to eq 302
    end
  end
end
