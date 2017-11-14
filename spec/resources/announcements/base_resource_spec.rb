require 'spec_helper'

describe Announcements::BaseResource do
  context "#read_all" do
    let(:account) { create(:account_with_permissions).tap{|acc| acc.owner = create(:user) }}
    let!(:announcements) { Array.new(1) { create(:announcement, account_id: account.id) }}
    

    it 'returns announcements for any user' do
      resource = Announcements::BaseResource.new(account: account, as: nil, params: {})
      expect(resource.read_all.result.collection.size).to eq(announcements.size)
    end
  end
end
