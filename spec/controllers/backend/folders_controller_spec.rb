require "spec_helper"

describe Backend::FoldersController do
  include Devise::TestHelpers
  render_views

  let(:account) { create(:account) }
  let(:another_account) { create(:account) }
  let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}
  let(:user)    { create(:confirmed_user).tap{|user| user.primary_account = another_account }}
  let(:gallery) { create(:gallery, account_id: account.id) }
  let(:folder)  { create(:folder, gallery_id: gallery.id) }
  let(:another_folder)  { create(:folder, gallery_id: gallery.id) }
  let(:params)  { {order: { folder.id => "1", another_folder.id =>"2"}, gallery_id: gallery.id }}

  context "#index" do
    it 'returns all account folders' do
      sign_in owner
      controller.stubs(:current_account).returns(account)

      folders = [
        folder,
        create(:folder, gallery_id: create(:gallery, account_id: account.id).id)
      ]

      get 'index', format: :json

      expect(response.status).to eq 200
      expect(JSON.parse(response.body).map{|b| b['id']}).to eq(folders.map(&:id))
    end

    it 'returns folders for selected gallery' do
      sign_in owner
      controller.stubs(:current_account).returns(account)

      folders = [
        folder,
        create(:folder, gallery_id: create(:gallery, account_id: account.id).id)
      ]

      get 'index', format: :json, gallery_id: gallery.id

      expect(response.status).to eq 200
      expect(JSON.parse(response.body).map{|b| b['id']}).to eq([folder.id])
    end
  end

  context "#reorder" do

    it 'should be available for owner' do
      controller.stubs(:current_account).returns(account)
      sign_in owner
      post :reorder, params.merge(format: :json)
      expect(response.status).to eq 200
    end

    it 'should not be available for non authorized users' do
      controller.stubs(:current_account).returns(account)
      sign_in user
      post :reorder, params.merge(format: :json)
      expect(response.status).to eq 401
    end
  end
end
