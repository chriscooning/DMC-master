class UserToken < ActiveRecord::Base
  belongs_to :user
  belongs_to :account

  scope :active, -> { where("enable_at < :now and expire_at > :now", now: Time.now) }

  validates :enable_at, :expire_at, presence: true

  before_validation :generate_token

  private

    def generate_token
      self.token ||= SecureRandom.urlsafe_base64(30).tr('lIO0', 'sxyz')
    end
end
