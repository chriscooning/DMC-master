class Events::BaseDecorator < Cyrax::Decorator

  def subject_name
    subject.full_name if subject.is_a?(User)
  end

  def created_at_display
    I18n.l(created_at, format: :display)
  end

end