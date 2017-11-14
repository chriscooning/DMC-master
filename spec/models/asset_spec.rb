require 'spec_helper'

describe Asset do

  describe "type checking" do
    let(:account)   { create(:account_with_permissions) }
    let(:gallery)   { create(:gallery, account: account) }
    let(:folder)    { create(:folder, gallery: gallery) }
    let(:image)     { create(:asset, folder: folder, account: account, file_content_type: 'image/jpg') }
    let(:video)     { create(:asset, folder: folder, account: account, file_content_type: 'video/mp4') }
    let(:audio)     { create(:asset, folder: folder, account: account, file_content_type: 'audio/mp3') }
    let(:document)  { create(:asset, folder: folder, account: account, file_content_type: 'application/pdf') }
    let(:undefined) { create(:asset, folder: folder, account: account, file_content_type: 'undefined') }

    it "image id" do
      expect(image.image?).to    be_true
      expect(image.video?).to    be_false
      expect(image.audio?).to    be_false
      expect(image.document?).to be_false
    end

    it "video is" do
      expect(video.image?).to    be_false
      expect(video.video?).to    be_true
      expect(video.audio?).to    be_false
      expect(video.document?).to be_false
    end

    it "audio is" do
      expect(audio.image?).to    be_false
      expect(audio.video?).to    be_false
      expect(audio.audio?).to    be_true
      expect(audio.document?).to be_false
    end

    it "document is" do
      expect(document.image?).to    be_false
      expect(document.video?).to    be_false
      expect(document.audio?).to    be_false
      expect(document.document?).to be_true
    end

    it "undefined is" do
      expect(undefined.image?).to    be_false
      expect(undefined.video?).to    be_false
      expect(undefined.audio?).to    be_false
      expect(undefined.document?).to be_true
    end
  end
end
