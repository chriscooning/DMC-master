require "spec_helper"

describe Frontend::GalleriesController do
  render_views

  include AuthHelper
  before(:each) do
    http_login
  end
  
  let(:account) { create(:account) }
  let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}
  let(:gallery) { create(:gallery, account_id: account.id) }
  let(:folder)  { create(:folder, gallery_id: gallery.id) }


  context "#portal" do
    it "unprotected account can be viewed by any user" do
      controller.stubs(:current_account).returns(account)
      get :portal, format: :html
      expect(response.status).to eq 200
    end

    it "render first gallery if such exists" do
      gallery = create(:gallery, account_id: account.id, show_first: true)
      controller.stubs(:current_account).returns(account)
      get :portal, format: :html
      expect(response.status).to eq 200
    end
  end

  context "#show" do
    it "render gallery" do
      controller.stubs(:current_account).returns(account)
      get :portal, format: :html, id: gallery.id
      expect(response.status).to eq 200
    end
  end
end
