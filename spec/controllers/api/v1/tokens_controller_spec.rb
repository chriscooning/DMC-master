require "spec_helper"

describe Api::V1::TokensController do
  render_views

  let(:account) { create(:account) }
  let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}

  context "#create" do
    it "working" do
      post :create, format: :json, email: owner.email, password: 'foobar'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['token']).not_to be_nil
    end
  end

  context "#destroy" do
    it "working" do
      pending 'destroy token not implemented yet'
    end
  end

end
