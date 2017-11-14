class SubUsers::MyResource < SubUsers::BaseResource
  accessible_attributes :email, :full_name, :password, :organization, :location, role_ids: [], permission_ids: []

  def create
    create! do |resource|
      resource.primary_account = account
    end
  end

  private

    def build_resource(id, attributes = {})
      role_ids        = attributes.delete(:role_ids) || []
      permission_ids  = attributes.delete(:permission_ids) || []

      if attributes[:password].present?
        attributes[:password_confirmation] ||= attributes[:password]
      else
        attributes.delete(:password)
        attributes.delete(:password_confirmation)
      end
      
      super(id, attributes).tap do |resource|
        resource.password_expired = true
        resource.attributes = attributes

        if invite.present?
          permission_ids += invite.gallery.read_permissions.map(&:id)
          resource.email = invite.email if resource.email.blank?
        end

        PermissionsAssigner.new(account: account, resource: resource).process(role_ids, permission_ids)
      end
    end
end
