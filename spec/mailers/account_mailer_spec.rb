require 'spec_helper'

describe AccountMailer do
  let(:user) { build(:user) }
  let(:token) { 'random_token_or_etc' }

  context '#reconfirmation_instructions' do
    it "should create template" do
      AccountMailer.reconfirmation_instructions(user, token).should be_kind_of(Mail::Message)
    end
  end

  context '#confirmation_instructions' do
    it "should create template" do
      AccountMailer.confirmation_instructions(user, token).should be_kind_of(Mail::Message)
    end
  end

  context '#reset_password_instructions' do
    it "should create template" do
      AccountMailer.reset_password_instructions(user, token).should be_kind_of(Mail::Message)
    end
  end
end
