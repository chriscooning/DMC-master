require 'spec_helper'

describe Assets::BaseResource do
  let(:account) { create(:account) }
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let!(:gallery) { create(:gallery, account: account) }

  let(:sub_user)    { create(:user).tap{|new_user| 
    account.users << new_user
    new_user.permissions << gallery.permissions
  }}

  let(:auth_hash) { 'some_secret_token_storing_in_cookies' }

  def create_with_asset(factory_name, options = {})
    options.reverse_merge!(gallery_id: gallery.id)

    create(factory_name, options).tap do |folder|
      create(:asset, folder_id: folder.id, account_id: account.id)
    end
  end

  let(:public_folder) { create_with_asset(:folder) }
  let(:hidden_folder) { create_with_asset(:hidden_folder) }
  let(:passworded_folder) { create_with_asset(:passworded_folder) }

  context "#read_all" do
    context "account owner" do
      def subject(request_params = {})
        args = { account: account, as: owner,
          params: request_params.reverse_merge(gallery_id: gallery.id)
        }
        Assets::BaseResource.new(args)
      end

      it "don't load assets from invisible folder" do
        expect{
          subject(folder_id: hidden_folder.id).read_all
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "load assets from protected folder" do
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id).to_a)
      end

      it "load asset from public folders" do
        expect(
          subject(folder_id: public_folder.id).read_all[:result].map(&:id)
        ).to eq(public_folder.assets.map(&:id))
      end
    end

    context "sub-user" do
      def subject(request_params = {})
        args = { account: account, as: sub_user, auth_hash: auth_hash,
          params: request_params.reverse_merge(gallery_id: gallery.id)
        }
        Assets::BaseResource.new(args)
      end

      it "don't load assets from invisible folder" do
        expect{
          subject(folder_id: hidden_folder.id).read_all
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "don't load assets from protected folder" do
        expect{
          subject(folder_id: passworded_folder.id).read_all
        }.to raise_error(Errors::PasswordRequired)
      end

      it "load assets from protected folder if user have read_permission" do
        sub_user.permissions << passworded_folder.permissions
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end

      it "load assets from protected folder if user knows password" do
        FolderAuthorizedKey.create(key: auth_hash, folder_id: passworded_folder.id)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end

      it "load asset from public folders" do
        expect(
          subject(folder_id: public_folder.id).read_all[:result].map(&:id)
        ).to eq(public_folder.assets.map(&:id))
      end
    end

    context "guest" do
      def subject(request_params = {})
        args = { account: account, as: nil, auth_hash: auth_hash,
          params: request_params.reverse_merge(gallery_id: gallery.id)
        }
        Assets::BaseResource.new(args)
      end

      it "don't load assets from invisible folder" do
        expect{
          subject(folder_id: hidden_folder.id).read_all
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "don't load assets from protected folder" do
        expect{
          subject(folder_id: passworded_folder.id).read_all
        }.to raise_error(Errors::PasswordRequired)
      end

      it "load assets from protected folder if user knows password" do
        FolderAuthorizedKey.create(key: auth_hash, folder_id: passworded_folder.id)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end

      it "load asset from public folders" do
        expect(
          subject(folder_id: public_folder.id).read_all[:result].map(&:id)
        ).to eq(public_folder.assets.map(&:id))
      end
    end
  end

  context "#query" do
    context "account owner" do
      def subject(request_params = {})
        args = { account: account, as: owner,
          params: request_params.reverse_merge(query: 'Image', gallery_id: gallery.id)
        }
        Assets::BaseResource.new(args)
      end

      it "don't search items from invisible folders" do
        expect(hidden_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: hidden_folder.id).read_all[:result].map(&:id)
        ).to be_empty
      end

      it "search from password protected folders" do
        expect(passworded_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end

      it "search items from public folders" do
        expect(public_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: public_folder.id).read_all[:result].map(&:id)
        ).to eq(public_folder.assets.map(&:id))
      end
    end

    context "sub-user" do
      def subject(request_params = {})
        args = { account: account, as: sub_user, auth_hash: auth_hash,
          params: request_params.reverse_merge(query: 'Image', gallery_id: gallery.id)
        }
        Assets::BaseResource.new(args)
      end

      it "search items from public folders" do
        expect(public_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: public_folder.id).read_all[:result].map(&:id)
        ).to eq(public_folder.assets.map(&:id))
      end

      it "don't search items from invisible folders" do
        expect(hidden_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: hidden_folder.id).read_all[:result].map(&:id)
        ).to be_empty
      end

      it "don't search assets from password protected folders" do
        expect(passworded_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to be_empty
      end

      it "search assets from password protected folders if user have password" do
        FolderAuthorizedKey.create(folder_id: passworded_folder.id, key: auth_hash)

        expect(passworded_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end

      it "search assets from password protected folders if user have read_permission" do
        sub_user.permissions << passworded_folder.permissions

        expect(passworded_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end
    end

    context "guest" do
      def subject(request_params = {})
        args = { account: account, as: nil, auth_hash: auth_hash,
          params: request_params.reverse_merge(query: 'Image', gallery_id: gallery.id)
        }
        Assets::BaseResource.new(args)
      end

      it "can search items from public folders" do
        expect(public_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: public_folder.id).read_all[:result].map(&:id)
        ).to eq(public_folder.assets.map(&:id))
      end

      it "don't search items from invisible folders" do
        expect(hidden_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: hidden_folder.id).read_all[:result].map(&:id)
        ).to be_empty
      end

      it "don't search assets from password protected folders" do
        expect(passworded_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to be_empty
      end

      it "search assets from password protected folders if user have password" do
        FolderAuthorizedKey.create(folder_id: passworded_folder.id, key: auth_hash)

        expect(passworded_folder.assets.size).to eq(1)
        expect(
          subject(folder_id: passworded_folder.id).read_all[:result].map(&:id)
        ).to eq(passworded_folder.assets.map(&:id))
      end
    end
  end
end
