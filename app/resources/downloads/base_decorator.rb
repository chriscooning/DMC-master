class Downloads::BaseDecorator < Cyrax::Decorator
  include Rails.application.routes.url_helpers

  def target_title
    target.try(:title) || "Deleted"
  end

  def created_at_display
    I18n.l(created_at, format: :shortened)
  end

  def subject_name
    if subject
      subject.full_name
    else
      "Anonym"
    end
  end

  def file_file_name
    target.file_file_name if target
  end

  def as_json(options = {})
    methods = [:file_url, :is_image, :thumb_url, :medium_url, :is_video, :gallery_id, :m3u8_url]
    resource.target.as_json(methods: methods, only: [:id, :folder_id, :title])
  end
end
