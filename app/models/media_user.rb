# class obsoleted, but we still need definition of class
# to access db [in order to convert existing data]
class MediaUser < ActiveRecord::Base
#  attr_accessor :terms_of_use
#
#  devise :database_authenticatable, :registerable,
#         :recoverable, :rememberable, :trackable, :validatable
#
#  validates :name, :phone, :outlet, presence: true
#  validates :terms_of_use, acceptance: true, on: :create
#  
#
#  has_many :authorizations, class_name: 'MediaAuthorization', dependent: :destroy
end
