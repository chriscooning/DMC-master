require 'spec_helper'

# it's more like integration spec - don't stub authorization services
# and other 

def add_read_permission(user, resource)
  permission = resource.permissions.where(action: 'read')
  raise "resource without 'read' permissions" if permission.blank?

  if !user.permissions.include?(permission) 
    user.permissions << permission
  end
end

describe Galleries::BaseResource do
  let(:account)   { create(:account) }
  let(:owner)     { create(:user).tap{|new_user| account.owner = new_user}}
  let(:user)      { create(:user_without_account).tap{|new_user| new_user.primary_account = account}}
  let(:gallery)   { create(:gallery, account_id: account.id) }
  let(:invisible_gallery) {
    create(:gallery, visible: false, account_id: account.id)
  }
  let(:gallery_protected_with_password) { 
    create(:gallery, enable_password: true, password: '123456', account_id: account.id)
  }
  let(:invite_only_gallery) {
    create(:gallery, enable_invitation_credentials: true, account_id: account.id)
  }

  context "account owner" do
    def resource_args
      { as: owner, account: account }
    end

    it "haven't access to invisible gallery" do
      expect {
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: invisible_gallery.id }
        )).read
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "can't view invisible gallery in list" do
      galleries = [gallery, invisible_gallery, gallery_protected_with_password, invite_only_gallery]
      galleries_list = Galleries::BaseResource.new(resource_args).read_all.result.to_a

      expect(galleries_list.size).to eq(3)
      expect(galleries_list.map(&:id).include?(invisible_gallery.id)).to be_false
    end

    it "can view password protected gallery without password" do
      subject = Galleries::BaseResource.new(resource_args.merge(
        params: { id: gallery_protected_with_password.id }
      ))
      expect(subject.read.result).to eq(gallery_protected_with_password)
    end

    it "can view invitation credentialed gallery" do
      expect(
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: invite_only_gallery.id }
        )).read.result
      ).to eq(invite_only_gallery)
      # not_to raise_error(Errors::InviteAuthorizationRequired)
    end

    it "can view public gallery" do
      expect(
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: gallery.id }
        )).read.result
      ).to eq(gallery)
    end
  end

  context "logged user" do
    def resource_args
      { as: user, account: account }
    end

    it "haven't access to invisible gallery" do
      expect {
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: invisible_gallery.id }
        )).read
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "can't view invisible gallery in list" do
      galleries = [gallery, invisible_gallery, gallery_protected_with_password, invite_only_gallery]
      galleries.map {|g| add_read_permission(user, g) }

      galleries_list = Galleries::BaseResource.new(resource_args).read_all.result.to_a

      expect(galleries_list.size).to eq(3)
      expect(galleries_list.map(&:id).include?(invisible_gallery.id)).to be_false
    end

    it "can view password protected gallery if have read permission" do
      subject = Galleries::BaseResource.new(resource_args.merge(
        params: { id: gallery_protected_with_password.id }
      ))
      add_read_permission(user, gallery_protected_with_password)
      expect(subject.read.result).to eq(gallery_protected_with_password)
    end

    it "can't view password protected gallery without password if haven't read permission" do
      subject = Galleries::BaseResource.new(resource_args.merge(
        params: { id: gallery_protected_with_password.id }
      ))
      expect{
        subject.read
      }.to raise_error(Errors::PasswordRequired)
    end

    it "can view invitation only gallery if have read permission" do
      subject = Galleries::BaseResource.new(resource_args.merge(
          params: { id: invite_only_gallery.id }
      ))
      add_read_permission(user, invite_only_gallery)
      expect(subject.read.result).to eq(invite_only_gallery)
    end

    it "can't view invitation only gallery if haven't read permission" do
      subject = Galleries::BaseResource.new(resource_args.merge(
          params: { id: invite_only_gallery.id }
      ))
      expect{ subject.read }.to raise_error(Errors::InviteAuthorizationRequired)
    end

    it "can view public gallery" do
      expect(
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: gallery.id }
        )).read.result
      ).to eq(gallery)
    end
  end

  context "guest" do
    def resource_args
      { as: nil, account: account }
    end

    it "haven't access to invisible gallery" do
      expect {
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: invisible_gallery.id }
        )).read
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "can't view invisible gallery in list" do
      galleries = [gallery, invisible_gallery, gallery_protected_with_password, invite_only_gallery]
      galleries.map {|g| add_read_permission(user, g) }
      galleries_list = Galleries::BaseResource.new(resource_args).read_all.result.to_a

      expect(galleries_list.size).to eq(3)
      expect(galleries_list.map(&:id).include?(invisible_gallery.id)).to be_false
    end

    it "can't view password protected gallery [only with password]" do
      expect {
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: gallery_protected_with_password.id }
        )).read
      }.to raise_error(Errors::PasswordRequired)
    end

    it "can't view invitation only gallery [ can't send request ]" do
      expect{
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: invite_only_gallery.id }
        )).read.result
      }.to raise_error(Errors::InviteAuthorizationRequired)
    end

    it "can view public gallery" do
      expect(
        Galleries::BaseResource.new(resource_args.merge(
          params: { id: gallery.id }
        )).read.result
      ).to eq(gallery)
    end
  end

  context "password protected gallery" do
    let(:token) { 'some_unique_token_stored_in_cookies' }

    it "can be accessed by guest with correct password" do
      GalleryAuthorizedKey.create(
        gallery_id: gallery_protected_with_password.id,
        key: token
      )
      # set gallery authorized key
      subject = Galleries::BaseResource.new(
        account: account,
        params: { id: gallery_protected_with_password.id },
        auth_hash: token,
      )
      expect(subject.read.result).to eq(gallery_protected_with_password)
    end
  end
end
