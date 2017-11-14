class Assets::ReportDecorator < Cyrax::Decorator

  def gallery_id
    folder.try(:gallery_id)
  end

  def gallery_name
    folder.try(:gallery).try(:name)
  end

  def folder_name
    folder.try(:name)
  end

  def as_json(options = {})
    methods = [:file_url, :is_image, :thumb_url, :medium_url, :is_video, :gallery_id, :m3u8_url]
    resource.as_json(methods: methods, only: [:id, :folder_id, :title])
  end
end