class Event < ActiveRecord::Base
  EVENT_NAMES = %w(download)
  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true
  belongs_to :target_owner, class_name: 'Account'

  validates :name, inclusion: { in: Event::EVENT_NAMES }

  EVENT_NAMES.each do |event|
    scope event.to_sym, -> { where(name: event) }
  end
end
