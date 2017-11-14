class Role < ActiveRecord::Base
  belongs_to :account
  has_and_belongs_to_many :users, join_table: :user_roles
  has_and_belongs_to_many :permissions, join_table: :roles_permissions

  validates :name, presence: true
end
