module Authentication
  module ModelHelper

    extend ActiveSupport::Concern

    included do
      class_name = "#{name}AuthorizedKey"
      has_many :authorized_keys, class_name: class_name, dependent: :destroy
      validates :password, presence: true, length: { minimum: 6 }, if: :password_enabled?
    end

    def password_authorized?(hash)
      !enable_password || authorized_keys.exists?(key: hash)
    end

    def authorized?(hash)
      password_authorized?(hash)
    end

    def valid_password?(password)
      return false if encrypted_password.blank?
      bcrypt   = ::BCrypt::Password.new(encrypted_password)
      password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)
      Devise.secure_compare(password, encrypted_password)
    end

    def invitations_requests_enabled?
      false
    end

    def protected?
      enable_credentials? || enable_password?
    end

    private

      def password_enabled?
        enable_password_changed? && enable_password?
      end
  end
end
