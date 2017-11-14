class Permission < ActiveRecord::Base
  belongs_to :account
  belongs_to :resource, polymorphic: true

  has_and_belongs_to_many :users, join_table: :users_permissions
  has_and_belongs_to_many :roles, join_table: :roles_permissions

  acts_as_paranoid

  # ? validate with authorizer??
  validates :action, inclusion: %w{read edit create_assets update_assets create_folders sort_folders create_galleries sort_galleries view_analytics view_subaccounts edit_subaccounts}

  scope :folders,   -> { where(resource_type: 'Folder') }
  scope :galleries, -> { where(resource_type: 'Gallery') }
  scope :common,    -> { where("resource_type is null or resource_type = 'Account'") }
  scope :editable,  -> { where(action: 'edit') }
  scope :readable,  -> { where(action: 'read') }

  scope :for_account, -> ( account ) { where(account_id: account.id) }

  # TODO - move to decorator
  def description
    "#{action}".gsub(/_/,' ')
  end

  def full_description
    if resource.present?
      "#{action.downcase} #{resource_type.downcase} #{resource.name}".gsub(/_/,' ') 
    else
      description
    end
  end
end
