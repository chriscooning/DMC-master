require 'spec_helper'

describe Permission do
  describe "account scope" do
    let(:account) { create(:account_with_permissions).tap{|acc| acc.owner = create(:user) }}
    let(:owner)   { create(:user).tap{|new_user| account.owner = new_user}}
    let(:user)    { create(:user).tap{|new_user| account.users << new_user }}
    let(:gallery) { create(:gallery,  account_id: account.id) }
    let(:folder)  { create(:folder,   gallery_id: gallery.id) }

    it "#common returns global account permissions" do
      expect(account.permissions.common.map(&:id)).to eq(account.permissions.map(&:id))
    end

    it "#galleries returns gallery permissions" do
      result = gallery.permissions.map(&:id)
      expect(account.permissions.galleries.map(&:id)).to eq(result)
    end

    it "#folders returns folder permissions" do
      result = folder.permissions.map(&:id)
      expect(account.permissions.folders.map(&:id)).to eq(result)
    end
  end
end
