require "spec_helper"

describe Backend::AssetsController do
  include Devise::TestHelpers
  render_views

  let(:account) { create(:account) }
  let(:another_account) { create(:account) }
  let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}
  let(:user)    { create(:confirmed_user).tap{|user| user.primary_account = another_account }}
  let(:gallery) { create(:gallery, account_id: account.id) }
  let(:folder)  { create(:folder, gallery_id: gallery.id) }

  context "#index" do
    it "should be availabe for owner" do
      controller.stubs(:current_account).returns(account)
      sign_in owner
      get :index, format: :json, gallery_id: gallery.id, folder_id: folder.id
      expect(response.status).to eq 200
    end

    it "should not be available for non-authorized" do
      pending "publicly available assets can viewed on backend?"

      controller.stubs(:current_account).returns(account)
      sign_in user
      get :index, format: :json, gallery_id: gallery.id, folder_id: folder.id
      expect(response.status).to eq 401
    end

    it "should be availabe for authorized invited users" do
      controller.stubs(:current_account).returns(account)
      user.permissions << folder.permissions
      sign_in user
      get :index, format: :json, gallery_id: gallery.id, folder_id: folder.id
      expect(response.status).to eq 200
    end
  end
end
