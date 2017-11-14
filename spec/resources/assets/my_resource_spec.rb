require 'spec_helper'

describe Assets::MyResource do
  let(:account) { create(:account_with_permissions) }
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let(:user)    { create(:user_without_account).tap{|new_user| new_user.primary_account = account}}
  let(:gallery) { create(:gallery, account: account) }
  let(:folder)  { create(:folder, gallery: gallery) }
  let(:asset)   { create(:downloadable_asset, folder: folder, account: account) }

  context "#search" do
    it 'should search through all items' do
      resource = Assets::MyResource.new(
        as: owner, account: account, params: { gallery_id: gallery.id, query: asset.title }
      )
      
      result = resource.read_all.result
      expect(result.resource[:result].size).to eq(1)
    end

    it 'should query only accessible elements' do
      user.permissions << gallery.permissions

      resource = Assets::MyResource.new(
        as: user, account: account, params: { gallery_id: gallery.id, query: asset.title }
      )

      result = resource.read_all.result
      expect(result.resource[:result].size).to eq(0)
    end
  end

  context '#update' do
    let(:other_folder)  { create(:folder, gallery: gallery) }
    let!(:first_creted_asset)   { create(:downloadable_asset, folder: other_folder, account: account) }
    it 'set highest position in new folder if folder changed' do
      subject = Assets::MyResource.new(as: owner, account: account, params: {
        id: asset.id,
        asset: {
          folder_id: other_folder.id
        }})
      result = subject.update.result
      expect(result.position).to be > first_creted_asset.position
    end
  end

  context "#update_multiple" do
    it "process several assets" 
    it "creates single default folder"
    it "can assign different folder"
    it "can assign different gallery"
  end
end
