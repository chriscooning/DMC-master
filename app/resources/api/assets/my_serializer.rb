class Api::Assets::MySerializer < Cyrax::Serializer
  attributes :id, :title, :description, :asset_type, :document_type,
             :folder_id, :file_url, :is_image, :thumb_url, :medium_url,
             :is_video, :quicklink_hash, :quicklink_url, :quicklink_valid_to,
             :quicklink_downloadable, :embedding_hash, :is_pdf, :pdf_preview_url,
             :video_urls, :downloadable, :type_icon_url, :custom_thumbnail_url,
             :is_processed

  def serialize
    if resource.respond_to?(:collection)
      result = self.class.scope.serialize(resource)
      { total_count: total_count, collection: result }
    else
      super
    end
  end

  def collection
    resource.presented_collection
  end

  def total_count
    resource.total_count
  end
end
