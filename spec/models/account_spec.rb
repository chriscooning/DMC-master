require 'spec_helper'

describe Account do
  before { pending }
  context "account logo" do
    let(:subject) { build(:account) }
    it "should set user's logo" do
      subject.logo = File.open(Rails.root.join('spec/fixtures/image.png'))
      subject.save
      subject.logo.exists?.should be_true
    end
  end
end
