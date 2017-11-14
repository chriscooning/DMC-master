require 'spec_helper'

describe Galleries::MyResource do
  describe '#toggle_first' do
    let(:user)    { create(:user) }
    let(:account)    { create(:account) }
    let(:params)  { Hash.new }
    let(:subject) do
      Galleries::MyResource.new(as: user, account: account, params: params)
    end

    it "should raise error for protected resource" do
      mock_resource = stub(:protected? => true, :show_first? => false)
      subject.stubs(:find_resource).returns(mock_resource)
      subject.stubs(:authorize_resource!).returns(true)

      subject.toggle_first.result.resource.should eq(mock_resource)
    end

    it 'should update galleries' do
      mock_resource = stub(:protected? => false, :show_first? => false)
      mock_resource.expects(:update_column).with(:show_first, true)
      subject.stubs(:find_resource).returns(mock_resource)
      subject.stubs(:authorize_resource!).returns(true)

      subject.toggle_first.result.resource.should eq(mock_resource)
    end

    it 'should reset resource' do
      mock_resource = stub(:show_first? => true)
      mock_resource.expects(:update_column).with(:show_first, false)
      subject.stubs(:find_resource).returns(mock_resource)
      subject.stubs(:authorize_resource!).returns(true)

      subject.toggle_first.result.resource.should eq(mock_resource)
    end
  end

  describe "#create" do
    let(:account) { create(:account) }
    let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
    let(:user)    { create(:user).tap{|new_user| new_user.accounts << account}}
    let(:params)  { { gallery: attributes_for(:gallery, account_id: account.id) }}
    let(:subject) do
      Galleries::MyResource.new(as: user, account: account, params: params).tap do |service|
        service.stubs(:authorize_resource!).returns(true)
      end
    end

    it "should create set of permissions for resource" do
      gallery = subject.create.result.resource # response -> decorator -> model
      expect(gallery).to be_kind_of(Gallery)
      expect(gallery.permissions.size).to eq(4)
    end

    it "should assign all permission on resource to creator" do
      gallery = subject.create.result.resource # response -> decorator -> model
      gallery.permissions.each do |permission|
        expect(user.permissions.include?(permission)).to be_true
      end
    end
  end

  describe "#read" do
    let(:account) { create(:account) }
    let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
    let(:user)    { create(:user).tap{|new_user| new_user.accounts << account}}
    let(:gallery) { create(:gallery, account_id: account.id) }
    let(:folder)  { create(:folder, gallery_id: gallery.id) }

    it 'works for owner' do
      available_folder = folder # load
      resource = Galleries::MyResource.new(as: owner, account: account, params: { id: gallery.id })
      result = resource.read

      expect(result.result.resource).to be_kind_of(Gallery)
      expect(result.assignments[:folders].size).to eq(1)
    end

    it 'workds for guest' do
      available_folder = folder # load
      user.permissions << gallery.permissions
      resource = Galleries::MyResource.new(as: user, account: account, params: { id: gallery.id })

      result = resource.read

      expect(result.result.resource).to be_kind_of(Gallery)
      expect(result.assignments[:folders].size).to eq(0)
    end
  end
end
