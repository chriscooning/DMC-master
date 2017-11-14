class Announcements::BaseDecorator < Cyrax::Decorator

  def created_at_display
    I18n.l(created_at, format: :display)
  end
end