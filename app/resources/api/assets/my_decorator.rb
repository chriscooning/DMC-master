class Api::Assets::MyDecorator < Cyrax::Decorator
  include ActionView::Helpers::AssetUrlHelper

  VIDEO_BITRATE = {
    mp4_360p: 800000,
    mp4_720p: 1500000
  }

  def type_icon_url
    if icon_type.present?
      "http://#{configatron.host}#{asset_path("/icons/file_types/#{icon_type}.png")}"
    else
      nil
    end
  end
  
  def custom_thumbnail_url(style = :medium)
    custom_thumbnail.present? ? custom_thumbnail.url(style) : nil
  end

  def is_processed
    processed?
  end

  def smil_video_urls
    video_urls.inject({}) do |result, type|
      height = type[0].to_s.match(/_(\d+)p/)[1]
      url = type[1].gsub(/http(s)?:\/\/([^\/]+)\//, '')
      result[height] = { url: url, bitrate: VIDEO_BITRATE[type[0]] }
      result
    end
  end
end
