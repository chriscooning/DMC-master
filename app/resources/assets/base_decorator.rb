class Assets::BaseDecorator < Cyrax::Decorator
  include Rails.application.routes.url_helpers

  VIDEO_BITRATE = {
    mp4_360p: 800000,
    mp4_720p: 1500000
  }

  def as_json(options = {})
    methods = [:is_image, :is_audio, :thumb_url, :medium_url, :is_video, :is_pdf, :pdf_preview_url, :icon_type, :audio_urls]
    only = [:id, :title, :description, :type, :downloadable, :video_urls, :folder_id, :m3u8_url, :file_file_name]
    resource.as_json(methods: methods, only: only)
  end

  def smil_video_urls
    video_urls.inject({}) do |result, type|
      height = type[0].to_s.match(/_(\d+)p/)[1]
      url = type[1].gsub(/http(s)?:\/\/([^\/]+)\//, '')
      result[height] = { url: url, bitrate: VIDEO_BITRATE[type[0]] }
      result
    end
  end

  def sharing_link_url
    embedded_url(embedding_hash, host: account.host)
  end

  def sharing_code
    "<iframe frameborder='0' src='#{sharing_link_url}' />"
  end
end
