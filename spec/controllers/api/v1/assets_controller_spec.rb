require "spec_helper"

describe Api::V1::AssetsController do
  render_views
  USER_TOKEN = 'test_token'

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @john = FactoryGirl.create(:confirmed_user)
    @john.authentication_token = USER_TOKEN
    @john.save
    @account = FactoryGirl.create(:account)
    @account.users << @john

    sign_in @john if !controller.user_signed_in?
  end

  describe "GET #index" do
    it "shows assets of specified folder" do
      gallery = FactoryGirl.create(:gallery, account_id: @account.id)
      folder  = FactoryGirl.create(:folder,  gallery: gallery)
      winter_photo = FactoryGirl.create(:asset, folder: folder)
      summer_photo = FactoryGirl.create(:asset, folder: folder)
      get :index, format: :json, user_token: USER_TOKEN, gallery_id: gallery.id, folder_id: folder.id
      expect(response.status).to eq 200
      results = JSON.parse(response.body)

      assets = results['collection']
      expect(results['total_count']).to eq 2
      asset = assets.first.with_indifferent_access
      expect(asset[:id]).to be_present
      expect(asset[:title]).to be_present
      expect(asset[:description]).to be_present
      expect(asset[:thumb_url]).to be_present
      expect(asset[:medium_url]).to be_present
      expect(asset[:asset_type]).to eq 'image'
      expect(asset[:document_type]).to be_nil
    end

    it "shows paginated assets of specified folder" do
      gallery = FactoryGirl.create(:gallery, account_id: @account.id)
      folder  = FactoryGirl.create(:folder,  gallery: gallery)
      winter_photo = FactoryGirl.create(:asset, folder: folder)
      summer_photo = FactoryGirl.create(:asset, folder: folder)
      get :index, format: :json,
        user_token: USER_TOKEN,
        gallery_id: gallery.id,
        folder_id: folder.id,
        page: 1,
        per:  1
      expect(response.status).to eq 200
      results = JSON.parse(response.body)
      expect(results['total_count']).to eq 2
      assets = results['collection']
      expect(assets.size).to eq 1
    end

    it "handles lack of parameters" do
      get :index, format: :json, user_token: USER_TOKEN
      expect(response.status).to eq 400
      result = JSON.parse(response.body).symbolize_keys!
      expect(result).to eq(message: "Please specify parameters: gallery_id, folder_id")

      get :index, format: :json, user_token: USER_TOKEN, gallery_id: 1
      expect(response.status).to eq 400
      result = JSON.parse(response.body).symbolize_keys!
      expect(result).to eq(message: "Please specify parameters: folder_id")

      get :index, format: :json, user_token: USER_TOKEN, folder_id: 1
      expect(response.status).to eq 400
      result = JSON.parse(response.body).symbolize_keys!
      expect(result).to eq(message: "Please specify parameters: gallery_id")
    end

    it "handles not found gallery" do
      get :index, format: :json, user_token: USER_TOKEN, gallery_id: "unknown_id", folder_id: "unknown_id"
      expect(response.status).to eq 404
      result = JSON.parse(response.body).symbolize_keys!
      expect(result).to eq(message: "Gallery not found")
    end

    it "handles not found folder" do
      gallery = FactoryGirl.create(:gallery, account_id: @account.id)
      get :index, format: :json, user_token: USER_TOKEN, gallery_id: gallery.id, folder_id: "unknown_id"
      expect(response.status).to eq 404
      result = JSON.parse(response.body).symbolize_keys!
      expect(result).to eq(message: "Folder not found")
    end
  end

  describe "GET #manifest" do
    it "returns manifest" do
      gallery = FactoryGirl.create(:gallery, account_id: @account.id)
      folder  = FactoryGirl.create(:folder,  gallery: gallery)
      winter_photo = FactoryGirl.create(:asset, folder: folder)
      get :manifest, format: :smil,
        user_token: USER_TOKEN,
        gallery_id: gallery.id,
        folder_id: folder.id,
        id:        winter_photo.id
      expect(response.status).to eq 200
      expect(response.body).to be_present
    end
  end
end
