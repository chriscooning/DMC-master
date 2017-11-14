require 'spec_helper'

describe VideoHandler do
  let(:account) { create(:account) }
  let(:gallery) { create(:gallery, account: account) }
  let(:folder)  { create(:folder, gallery: gallery) }
  let(:asset)   { create(:asset, folder: folder) }
  let(:subject) { VideoHandler.new }

  context "process" do
    it "should call 'submit'" do
      HeyWatch.expects(:submit)
      subject.expects(:configure_job).with(asset)

      subject.process(asset)
    end
  end

  context "configure_job" do
    it "should work" do
      expect(
        subject.send(:configure_job, asset)
      ).not_to be_nil
    end
  end

  context "process_robot_ping" do
    let(:asset) { create(:asset_with_secret, folder: folder) }
    let(:args) {{
      secret: asset.secret,
      output_urls: [
        ['mp4_360p', 'some_url'],
        ['mp4_720p', 'some_url'],
        ['jpg_550x', ['some_url']],
        ['jpg_1160x', ['some_url']],
        ['hls', 'some_url']
      ]
    }}

    it "should work" do
      expect(
        subject.process_robot_ping(args)
      ).to be_true # asset.save

      expect(
        Asset.find(asset.id).processed
      ).to be_true
    end
  end
end
