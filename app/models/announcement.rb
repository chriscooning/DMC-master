class Announcement < ActiveRecord::Base
  belongs_to :user

  validates :title, presence: true
  validates :text, presence: true, length: { maximum: 140 }
end