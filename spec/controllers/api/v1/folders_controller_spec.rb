require "spec_helper"

describe Api::V1::FoldersController do
  render_views

  let(:account) { create(:account) }
  let(:owner)   { create(:user_with_token).tap{|user| account.owner = user }}
  let(:gallery) { create(:gallery, account_id: account.id) }
  let(:folder)  { create(:folder, gallery_id: gallery.id) }

  context "#read_all" do
    it "returns all folders" do
      folder # load gallery

      get :index, format: :json, user_token: owner.authentication_token, gallery_id: folder.gallery_id
      expect(response.status).to eq 200

      result = JSON.parse(response.body).first
      expect(result['id']).to eq(folder.id)
      expect(result['name']).to eq(folder.name)
    end
  end
end
