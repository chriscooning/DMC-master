class MenuLink < ActiveRecord::Base
  belongs_to :gallery

  validates :link, :content, presence: true

  before_create :set_position
  before_save :handle_url

  private

    def handle_url
      self.link = "http://#{link}" unless link =~ /^http(s)?:\/\//
    end

    def set_position
      self.position = gallery.menu_links.maximum(:position).to_i + 1
    end
end