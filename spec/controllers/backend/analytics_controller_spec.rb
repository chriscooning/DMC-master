require "spec_helper"

describe Backend::AnalyticsController do
  include Devise::TestHelpers
  render_views

  let(:account) { create(:account) }
  let(:owner) { create(:confirmed_user).tap{|user| account.owner = user; account.save }}

  describe "#index" do
    it "should work" do
      sign_in owner
      get :index
      expect(response.status).to eq 200
    end
  end
end
