require 'spec_helper'

describe Galleries::BaseResource do
  let(:account)   { create(:account) }
  let(:owner)     { account.owner }
  let(:user)      { create(:user_without_account) }
  let(:gallery)   { create(:gallery, account_id: account.id) }

  context "#read" do
    let(:subject)   { Galleries::BaseResource.new(as: user, account: account, params: { id: gallery.id })}

    it 'raise not_found error if item invisible' do
      invisible_gallery = create(:gallery, account_id: account.id, visible: false)
      expect {
        Galleries::BaseResource.new(
          as: user, account: account, params: { id: invisible_gallery.id }
        ).read
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raise not_found error if item not exists' do
      not_existed_id = Gallery.maximum(:id).to_i.next
      expect {
        Galleries::BaseResource.new(as: user, account: account, params: { id: not_existed_id }).read
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should search by params[:id]" do
      subject.stubs(:available_folders).returns([])
      #subject.stubs(:readable_resource_ids).returns([gallery.id])
      #subject.stubs(:authorize_resource!).returns(true)
      #subject.stubs(:authorized?).returns(true)

      expect(subject.read.result).to eq(gallery)
    end

  end

  # it's a private method, but easier to test in separately
  context "#available_folders" do
    context 'in case of account owner' do
      let(:subject) do
        Galleries::BaseResource.new(
          as: owner,
          account: account,
          params: {}
        )
      end

      before :each do
        mock_auth_service = 'auth_service'
        mock_auth_service.stubs(:authorized?).returns(true)
        subject.stubs(:authorization_service).returns(mock_auth_service)
      end

      it 'should return empty hash if gallery have no folders' do
        expect(subject.send(:available_folders, gallery)).to be_empty
      end

      it 'should return all folders' do
        folders = Array.new(2) { create(:folder, gallery: gallery) }

        expect(subject.send(:available_folders, gallery)).to match_array(folders)
      end

      it 'should return visible folders' do
        folders = [ 
          create(:folder, gallery: gallery),
          create(:hidden_folder, gallery: gallery)
        ]
        expect(subject.send(:available_folders, gallery)).to eq([folders.first])
      end

      it 'should return password protected folders'
    end

    context 'in case of ordinary user' do
      let(:subject) do
        Galleries::BaseResource.new(
          as: user,
          account: account,
          params: {}
        )
      end

      before :each do
        mock_auth_service = 'auth_service'
        mock_auth_service.stubs(:authorized?).returns(true)
        subject.stubs(:authorization_service).returns(mock_auth_service)
      end

      it 'should return empty hash if gallery have no folders' do
        expect(subject.send(:available_folders, gallery)).to be_empty
      end

      #it 'should return only accessible folders' do
      #  folders = Array.new(2) { create(:folder, gallery: gallery) }
      #  expect(subject.send(:available_folders, gallery)).to eq([folders.last])
      #end

      it 'should return visible folders' do
        folders = [ 
          create(:folder, gallery: gallery),
          create(:hidden_folder, gallery: gallery)
        ]
        expect(subject.send(:available_folders, gallery)).to eq([folders.first])
      end

      it 'should return password protected folders'
    end
  end
end
