class Account < ActiveRecord::Base
  include Authentication::SubdomainModelHelper
  attr_accessor :delete_logo, :invitation_hash, :delete_portal_header_image

  RESERVED_SUBDOMAINS = %w(admin api blog)

  serialize :theme, Hash

  has_many :users, through: :account_users
  has_many :account_users

  has_many :primary_account_users, -> { where(primary: true) }, class_name: 'AccountUser'
  has_many :primary_users, through: :primary_account_users, source: :user

  has_many :galleries, -> { order('position ASC') }, dependent: :destroy
  has_many :folders, through: :galleries
  has_many :assets, dependent: :destroy
  #has_many :media_authorizations, foreign_key: 'target_owner_id', dependent: :destroy
  has_many :related_events, class_name: 'Event', foreign_key: 'target_owner_id'
  has_many :announcements, -> { order('created_at DESC') }, dependent: :destroy

  has_many :permissions
  has_many :roles

  validates :subdomain, presence: true, subdomain: true, length: { minimum: 3, maximum: 50 },
            uniqueness: { case_sensitive: false }, exclusion: { in: RESERVED_SUBDOMAINS }

  validates :welcome_message, length: { maximum: 280 }

  before_create :set_s3_hash
  before_save :handle_logo_url
  before_save :downcase_subdomain

  after_save :extract_logo_dimensions, if: :logo_updated_at_changed?

  has_attached_file :logo,
    styles: {
      original: 'x120>'
    },
    path: ":account_s3_hash/logo/:account_owner_id/:style/:filename"

  has_attached_file :portal_header_image,
    styles: {
      default: '1140x340#',
      thumb: '228x68#'
    },
    path: ":account_s3_hash/portal_header_image/:account_owner_id/:style/:filename"

  validates_attachment :portal_header_image, size: { less_than: 1.megabyte },
    content_type: { content_type: /image\/(jpeg|jpg|png|gif|bmp)/}

  def name
    owner.try(:full_name) || subdomain
  end

  def host
    "#{subdomain}.#{configatron.host}"
  end

  def owner
    @owner ||= begin
      owner_relation = account_users.where(owner: true).first
      owner_relation.present? ?  User.find(owner_relation.user_id) : nil
    end
  end

  def owner=(user)
    account_users.where(owner: true, user_id: user.id).first_or_create
    @owner = user
    user
  end

  def add_user(user: nil, primary: false, invited: true)
    relation = account_users.where(user_id: user.id).first_or_initialize
    relation.primary = primary
    relation.invited = invited
    relation.owner = false
    relation.save!
    relation
  end

  def hidden?
    false
  end

  private

    def handle_logo_url
      self.logo_url = "http://#{logo_url}" unless !logo_url.present? || logo_url =~ /^http(s)?:\/\//
    end

    def set_s3_hash
      self.s3_hash ||= [subdomain, SecureRandom.hex(8)].join('-')
    end

    def downcase_subdomain
      self.subdomain = subdomain.to_s.downcase
    end

    # this should be in account-creation-service
    def create_permissions
      %w{create_galleries sort_galleries view_analytics read edit view_subaccounts edit_subaccounts}.each do |action|
        permission = self.permissions.where(action: action).first_or_create
        if permission.resource.nil?
          permission.update_attributes(resource_id: self.id, resource_type: 'Account')
        end
      end
    end

    def extract_logo_dimensions
      if logo.blank?
        update_columns({
                        logo_height: nil,
                        logo_width: nil
                      })
      else
        geometry = Paperclip::Geometry.from_file(logo.queued_for_write[:original])
        update_columns({
                         logo_height: geometry.height.to_i,
                         logo_width: geometry.width.to_i
                       })
      end
    #rescue Errors::NotIdentifiedByImageMagickError
    rescue Exception => e
      Rails.logger.info(e)
    end

  public

    class << self
      def pepper
        User.pepper
      end
    end
end
