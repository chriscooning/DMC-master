require 'spec_helper'

describe Api::TokenAuthorizer do
  let!(:user) { create(:confirmed_user, email: 'vader@email.com', password: '123456', password_confirmation: '123456') }
  let(:service) { Api::TokenAuthorizer.new }

  describe "#create_token" do

    before(:each) { service.perform(:create_token, params) }

    describe "valid params" do
      let(:params) do
        { email: 'vader@email.com', password: '123456' }
      end

      it "" do
        service.status.should eq(200)
      end
    end

    describe "invalid params" do
      let(:params) do
        { email: 'vader@email.com', password: '123' }
      end

      it "" do
        service.status.should eq(401)
      end
    end
  end
end