class Gallery < ActiveRecord::Base
  include Authentication::ModelHelper
  attr_accessor :password

  acts_as_paranoid

  belongs_to :account
  belongs_to :user # stub, this should not be used anyway

  has_many :folders, -> { order('position ASC') }, dependent: :destroy
  has_many :assets, through: :folders
  has_many :menu_links, -> { order('position ASC') }, dependent: :destroy
  has_many :members, class_name: "GalleryMember", dependent: :destroy
  has_many :invites, class_name: "InvitationRequest", dependent: :destroy

  has_many :permissions, as: :resource, dependent: :destroy

  validates :name, presence: true

  validates :menu_links, length: { maximum: configatron.maximum_counts.menu_links }

  validates :gallery_message, length: { maximum: 1024 }

  accepts_nested_attributes_for :menu_links, allow_destroy: true

  has_attached_file :logo
  has_attached_file :featured_image,
    styles: { default: '540x300#' },
    path: ":account_s3_hash/featured_image/:id/:style/:filename"

  validates_attachment :featured_image, size: { less_than: 1.megabyte },
    content_type: { content_type: /image\/(jpeg|jpg|png|gif|bmp)/}

  validates_attachment_presence :featured_image, if: :featured?, message: "Please upload image"

  scope :visible, -> { where(visible: true) }

  def as_json(options = {})
    options[:only] ||= [
      :id, :name, :visible, :enable_invitation_credentials, 
      :enable_password, :show_first, :position,
      :gallery_message
    ]
    super(options)
  end

  def self.pepper
    'gallery'
  end

  def protected?
    super || enable_invitation_credentials?
  end

  def hidden?
    !visible?
  end

  def public?
    !(hidden? || enable_invitation_credentials? || enable_password?)
  end

  def invitations_requests_enabled?
    enable_invitation_credentials?
  end

  # NOTE: also, we should add the same permissions to creator of this.
  # possible, move this code to third place
  def create_permissions
    %w{read edit create_folders sort_folders}.each do |action|
      permissions.where(account_id: self.account_id, action: action).first_or_create
    end
  end

  def read_permissions(with_childs: true)
    read_permissions = permissions.where(action: 'read')
    folders.each do |folder|
      read_permissions += folder.permissions.where(action: 'read')
    end
    read_permissions.flatten
  end
end
