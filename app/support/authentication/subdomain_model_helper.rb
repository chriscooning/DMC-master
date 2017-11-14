module Authentication
  module SubdomainModelHelper

    extend ActiveSupport::Concern

    included do
      class_name = "SubdomainAuthorizedKey"
      has_many :authorized_keys, class_name: class_name, dependent: :destroy
      validates :subdomain_password, presence: true, if: :subdomain_password_enabled?
      attr_accessor :subdomain_password
    end

    def protected?
      enable_subdomain_password?
    end

    def authorized?(hash)
      password_authorized?(hash)
    end

    def password_authorized?(hash)
      !enable_subdomain_password || authorized_keys.exists?(key: hash)
    end

    # client can't send request 
    def invitations_requests_enabled?
      false
    end

    # valid password have name collision with devise
    def valid_subdomain_password?(password)
      return false if encrypted_subdomain_password.blank?
      bcrypt   = ::BCrypt::Password.new(encrypted_subdomain_password)
      password = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt.salt)
      Devise.secure_compare(password, encrypted_subdomain_password)
    end

    private

      def subdomain_password_enabled?
        enable_subdomain_password_changed? && enable_subdomain_password?
      end
  end
end
