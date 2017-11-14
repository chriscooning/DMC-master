class User < ActiveRecord::Base
  attr_accessor :invitation_hash, :skip_confirmation
  attr_accessor :subdomain

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts, through: :account_users
  has_many :account_users

  has_many :galleries, through: :accounts

  has_and_belongs_to_many :roles, join_table: :user_roles

  has_and_belongs_to_many :permissions, join_table: :users_permissions

  has_many :gallery_membership, class_name: 'GalleryMember', dependent: :destroy

  has_many :tokens, class_name: 'UserToken'

  validates :full_name, presence: true

  after_create :create_gallery_membership

  def name
    self.full_name
  end

  def account_owner?(account)
    #AccountUser.where(account_id: account.id, user_id: self.id, owner: true).exists?
    account_users.any?{|ac| ac.account_id == account.id and ac.owner? }
  end

  def primary_account
    self.accounts.where('account_users.primary' => true).first || self.accounts.first
  end

  def primary_account=(new_primary_account)
    if !accounts.include?(new_primary_account)
      accounts << new_primary_account
    end
    self.account_users.update_all(primary: false)
    self.account_users.where(account_id: new_primary_account.id).update_all(primary: true)

    new_primary_account
  end

  def can_access_backend?
    true
  end

  def send_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    email_name = pending_reconfirmation? ? :reconfirmation_instructions : :confirmation_instructions
    send_devise_notification(email_name, @raw_confirmation_token)
  end

  def hidden?
    false
  end

  private

    def create_gallery_membership
      GalleryInviter.new(as: self).create_membership
    end
end
