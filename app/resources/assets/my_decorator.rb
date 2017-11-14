class Assets::MyDecorator < Assets::BaseDecorator
  def as_json(options = {})
    methods = [
      :file_url, :is_image, :is_audio, :thumb_url, :medium_url, :is_video, :quicklink_hash,
      :quicklink_url, :quicklink_valid_to, :quicklink_downloadable, :embedding_hash, :is_pdf,
      :pdf_preview_url, :icon_type, :is_tiff, :audio_urls
    ]
    resource.as_json(methods: methods, except: [:file_content_type, :file_updated_at, :created_at, :updated_at, :account_id])
  end
end
