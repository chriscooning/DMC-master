class Users::ProfileResource < Users::BaseResource 
  accessible_attributes :email, :full_name, :password, :password_confirmation

  def find_resource(id = nil)
    User.find(accessor.id)
  end

  def build_resource(id, attributes = {})
    resource = accessor

    # cleanup password if it's blank
    if attributes[:password].blank? && attributes[:password_confirmation].blank?
      attributes.delete(:password)
      attributes.delete(:password_confirmation)
    end

    resource.attributes = attributes
    resource
  end

  def update
    old_encrypted_password = find_resource(accessor.id).encrypted_password
    update! do |resource|
      if password_changed?(resource.password, old_encrypted_password)
        resource.update_column(:password_expired, false)
      end
    end
  end

  private

    def password_changed?(password, encrypted_password)
      return false if password.nil?
      return true if encrypted_password.blank? 

      bcrypt   = ::BCrypt::Password.new(encrypted_password)
      password = ::BCrypt::Engine.hash_secret("#{password}#{User.pepper}", bcrypt.salt)
      old_password_valid = Devise.secure_compare(password, encrypted_password)
      !old_password_valid
    end
end
