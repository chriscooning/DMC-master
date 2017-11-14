require "spec_helper"
#require "rails_helper"

describe Frontend::BaseController do
  let!(:account) { create(:account) }

  context "#current_account" do
    it "returns account by 'subdomain'" do
      @request.host = "#{ account.subdomain }.example.com"
      expect(controller.send(:current_account)).to eq(account)
    end

    it "returns account by 'www.subdomain'" do
      @request.host = "www.#{ account.subdomain }.example.com"
      expect(controller.send(:current_account)).to eq(account)
    end

    it "raises error if no account with this subdomain" do
      @request.host = "i_would_be_very_surprized_if_there_will_be_such_subdomain.example.com"
      expect{
        controller.send(:current_account)
      }.to raise_error(Errors::InvalidSubdomain)
    end
  end
end
