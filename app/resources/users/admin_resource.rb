class Users::AdminResource < Cyrax::Resource
  resource :user
  accessible_attributes :email, :full_name, :password_expired, :subdomain, :password, :skip_confirmation

  def build_resource(id, attributes = {})
    if attributes[:password].present?
      attributes[:password_confirmation] = attributes[:password]
    end
    skip_confirmation = (attributes.delete(:skip_confirmation) == '1')

    super(id, attributes).tap do |user|
      user.skip_confirmation! if skip_confirmation
      user.skip_reconfirmation! if skip_confirmation
    end
  end

  private

  # resource only for admin users
  def authorize_resource!(action, resource)
    if accessor.blank? || !accessor.is_a?(AdminUser)
      raise 'AuthorizationError'
    end
  end
end
