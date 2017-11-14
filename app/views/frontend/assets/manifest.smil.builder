xml.smil do
  xml.head do
    xml.meta base: "rtmp://#{configatron.aws.cloudfront_host}/cfx/st/"
  end
  xml.body do
    xml.switch do
      @asset.smil_video_urls.each do |format, info|
        xml.video height: format, src: info[:url], "system-bitrate" => info[:bitrate]
      end
    end
  end
end