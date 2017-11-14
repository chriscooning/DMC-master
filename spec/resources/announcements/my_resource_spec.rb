require 'spec_helper'

describe Announcements::MyResource do
  # any user can read announcements
  context "#read_all" do
    let(:account) { create(:account_with_permissions).tap{|acc| acc.owner = create(:user) }}
    let!(:announcements) { Array.new(1) { create(:announcement, account_id: account.id) }}

    it 'returns announcements for any user' do
      resource = Announcements::MyResource.new(account: account, as: nil, params: {})
      expect(resource.read_all.result.collection.size).to eq(announcements.size)
    end
  end

  # only user with correct permisisons can create/update/destroy them
  context "management" do
    let(:account) { create(:account_with_permissions) }
    let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}
    let(:authorized_user) do
      create(:confirmed_user).tap do |user|
        user.primary_account = account
        user.permissions << account.permissions
      end
    end
    let(:guest) do
      create(:confirmed_user).tap{|user| user.primary_account = account }
    end
    let(:announcement) { create(:announcement, account_id: account.id) }

    context "#create" do
      it "works for authorized user" do
        attrs = attributes_for(:announcement)
        resource = Announcements::MyResource.new(
          account: account,
          as: authorized_user, 
          params: { announcement: attrs }
        )
        record = resource.create.result.resource
        expect(record.title).to eq(attrs[:title])
      end

      it "raises error for guest user" do
        resource = Announcements::MyResource.new(
          account: account,
          as: guest, 
          params: { announcement: attributes_for(:announcement) }
        )
        expect {
          resource.create
        }.to raise_error(Errors::AuthorizationRequired)
      end
    end

    context "#update" do
      it "works for authorized user" do
        attrs = attributes_for(:announcement)
        resource = Announcements::MyResource.new(
          account: account,
          as: authorized_user, 
          params: { id: announcement.id, announcement: attrs }
        )
        record = resource.update.result.resource
        expect(record.title).to eq(attrs[:title])
      end

      it "raises error for guest user" do
        attrs = attributes_for(:announcement)
        resource = Announcements::MyResource.new(
          account: account,
          as: guest, 
          params: { id: announcement.id, announcement: attrs }
        )
        expect {
          resource.update
        }.to raise_error(Errors::AuthorizationRequired)
      end
    end

    context "#destroy" do
      it "works for authorized user" do
        resource = Announcements::MyResource.new(
          account: account,
          as: authorized_user, 
          params: { id: announcement.id }
        )
        expect {
          resource.destroy
        }.not_to raise_error
        expect(Announcement.where(id: announcement.id).exists?).to be_false
      end

      it "raises error for guest user" do
        resource = Announcements::MyResource.new(
          account: account,
          as: guest, 
          params: { id: announcement.id }
        )
        expect {
          resource.destroy
        }.to raise_error(Errors::AuthorizationRequired)
      end
    end
  end
end
