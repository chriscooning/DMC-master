# class obsoleted, but we still need definition of class
# to access db [in order to convert existing data]
class MediaAuthorization < ActiveRecord::Base
#  STATUSES = %w(pending approved declined)
#
#  belongs_to :media_user
#  belongs_to :target, polymorphic: true
#  belongs_to :target_owner, class_name: 'Account'
#
#  scope :active, -> { where(status: 'approved') }
#  scope :declined, -> { where(status: 'declined') }
#  scope :pending, -> { where(status: 'pending') }
#
#  def for_gallery?
#    target_type == 'Gallery'
#  end
#
#  def for_folder?
#    target_type == 'Folder'
#  end
#
#  STATUSES.each do |status|
#   define_method :"#{status}?" do
#      self.status == status
#    end
#  end
end
