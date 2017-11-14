# model required only for access in data migration
class GalleryMember < ActiveRecord::Base
  ROLES = %w(admin viewer)
  belongs_to :gallery
  belongs_to :user

  ROLES.each do |role|
    scope role.to_sym, -> { where(role: role) }
  end

  validates :gallery_id, uniqueness: { scope: :user_id, message: "User is already invited to this gallery" }
end
