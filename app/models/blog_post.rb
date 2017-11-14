class BlogPost < ActiveRecord::Base
  attr_accessor :delete_image

  validates :title, presence: true

  has_attached_file :image, 
    styles: {
      small: "100x100>"
    },
    path: "blog/images/:id/:style/:filename"

  validates_attachment :image, content_type: { content_type: /image\/(jpeg|jpg|png|gif|bmp)/}

  paginates_per configatron.pagination.blog.per

  scope :published, -> { where('publish_at < ?', DateTime.now) }

  def name
    self.title
  end
end
