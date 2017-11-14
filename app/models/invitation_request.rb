class InvitationRequest < ActiveRecord::Base
  belongs_to :gallery
  belongs_to :user

  GalleryMember::ROLES.each do |role|
    scope role.to_sym, -> { where(role: role) }
  end

  validates :email, presence: true

#  validates :gallery_id, uniqueness: { scope: :email, case_sensitive: false, message: "This user has already invited" }

  delegate :account, to: :gallery
end
