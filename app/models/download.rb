class Download < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
  belongs_to :asset
  belongs_to :owner, class_name: "User"

  paginates_per 20
end