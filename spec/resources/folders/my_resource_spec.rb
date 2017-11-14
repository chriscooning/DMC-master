require 'spec_helper'

describe Folders::MyResource do

  context "#create" do
    let(:account) { create(:account) }
    let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
    let(:user)    { create(:user).tap{|new_user| new_user.accounts << account}}
    let(:gallery) { create(:gallery, account_id: account.id) }
    let(:params)  { HashWithIndifferentAccess.new(
      { folder: attributes_for(:folder), gallery_id: gallery.id }
    )}
    let(:subject) do
      Folders::MyResource.new(as: user, account: account, params: params).tap do |service|
        service.stubs(:authorize_resource!).returns(true)
      end
    end

    it "should create set of permissions for resource" do
      resource = subject.create.result
      expect(resource.resource).to be_kind_of(Folder)
      expect(resource.permissions.size).to eq(3)
    end

    it "should assign all permission on resource to creator" do
      resource = subject.create.result
      resource.permissions.each do |permission|
        expect(user.permissions.include?(permission)).to be_true
      end
    end
  end
end
