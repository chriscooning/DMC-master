class Folder < ActiveRecord::Base
  include Authentication::ModelHelper
  attr_accessor :password

  acts_as_paranoid

  belongs_to :gallery
  has_many :assets, -> { order("position DESC") }

  has_many :permissions, as: :resource, dependent: :destroy

  validates :name, presence: true, length: { maximum: 90 }

  scope :visible, -> { where(hide_folder: false) }

  after_destroy :clear_all_assets

  def as_json(options = {})
    super(except: [:created_at, :updated_at, :encrypted_password], include: :gallery)
  end

  def self.pepper
    '123456'
  end

  def account
    gallery.try(:account)
  end

  def hidden?
    hide_folder?
  end

  def public?
    !(hidden? || enable_password?)
  end

  def create_permissions
    return if self.account.blank?
    %w{read edit create_assets}.each do |action|
      permissions.where(account_id: self.account.id, action: action).first_or_create
    end
  end

  private

    def clear_all_assets
    end

end
