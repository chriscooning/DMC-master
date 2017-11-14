class BlogPosts::BaseDecorator < Cyrax::Decorator

  def publish_at_display
    I18n.l(publish_at, format: :display)
  end
end