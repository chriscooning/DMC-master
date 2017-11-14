require "spec_helper"

describe Backend::AnnouncementsController do
  include Devise::TestHelpers
  render_views

  let(:account) { create(:account) }
  let(:owner)   { create(:confirmed_user).tap{|user| account.owner = user }}
  let(:user)    { create(:confirmed_user).tap{|user| user.primary_account = another_account }}
  let(:announcement) { create(:announcement, account_id: account.id) }

  it "successfully rendered new page" do
    controller.stubs(:current_account).returns(account)
    sign_in owner
    get :new
    expect(response.status).to eq 200
  end

  it "creates new announcement" do
    controller.stubs(:current_account).returns(account)
    sign_in owner

    post :create, announcement: attributes_for(:announcement)
    expect(response.status).to eq 302 # created & redirected
    expect(Announcement.count).to eq(1)
  end

  it "successfully rendered edit" do
    controller.stubs(:current_account).returns(account)
    sign_in owner
    get :edit, id: announcement.id
    expect(response.status).to eq 200
  end

  it "updates announcement" do
    controller.stubs(:current_account).returns(account)
    sign_in owner

    put :update, id: announcement.id, announcement: { title: 'mytitle', text: 'text' }
    expect(response.status).to eq 302

    result = Announcement.last
    expect(result.title).to eq('mytitle')
  end

  it 'deletes announcement' do
    controller.stubs(:current_account).returns(account)
    sign_in owner

    delete :destroy, id: announcement.id
    expect(response.status).to eq 302

    expect(Announcement.count).to eq(0)
  end
end
