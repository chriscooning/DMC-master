require "spec_helper"

describe Api::V1::GalleriesController do
  render_views

  let(:account) { create(:account) }
  let(:owner)   { create(:user_with_token).tap{|user| account.owner = user }}
  let(:gallery) { create(:gallery, account_id: account.id) }

  context "#index" do
    it "return all galleries" do
      gallery # load gallery

      get :index, format: :json, user_token: owner.authentication_token
      expect(response.status).to eq 200

      result = JSON.parse(response.body).first
      expect(result['id']).to eq(gallery.id)
      expect(result['name']).to eq(gallery.name)
    end
  end
end
