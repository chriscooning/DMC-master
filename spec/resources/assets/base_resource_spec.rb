require 'spec_helper'

describe Assets::BaseResource do
  let(:account) { create(:account) }
  let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
  let(:gallery) { create(:gallery, account: account) }
  let(:folder) { create(:folder, gallery: gallery) }
  let(:asset) { create(:downloadable_asset, folder: folder, account: account) }
  let(:resource) do
    Assets::BaseResource.new(
      as: owner,
      account: account,
      params: {
        gallery_id: asset.folder.gallery_id,
        folder_id: asset.folder_id,
        id: asset.id
      }
    )
  end

  context "user requests download link" do
    let(:resource) do
      Assets::BaseResource.new(
        as: nil, # item should be available for any user
        account: account,
        params: {
          gallery_id: asset.folder.gallery_id,
          folder_id: asset.folder_id,
          id: asset.id
        }
      )
    end
    before { resource.download }
    
    it "creates download event" do
      asset.should have(1).events
    end
  end

  context "#embedded link" do
    let(:resource) do
      Assets::BaseResource.new( as: nil, account: account, params: { embedding_hash: asset.embedding_hash })
    end

    it "returns assets" do
      expect(resource.read_embedded.result.id).to eq(asset.id)
    end
  end

  context "quicklink" do
    it 'any user can read_quicklink'
    it 'any user can download_quicklink'
  end
end
