class SubUsers::InvitationResource < SubUsers::BaseResource
  accessible_attributes :email, role_ids: [], permission_ids: []

  # add existing user
  def create
    resource = User.where(email: resource_attributes[:email]).first
    authorize_resource!(:create, resource)

    if resource && resource.persisted? 
      relation = resource.account_users.where(account_id: account.id).first
      unless relation
        resource.account_users.create(account_id: account.id, primary: false, invited: true)
      end
    else
      resource.errors.add(:email, "invalid user email")
    end
  end

  private

    def build_resource(id, attributes = {})
      role_ids        = attributes.delete(:role_ids) || []
      permission_ids  = attributes.delete(:permission_ids) || []
      
      super(id, attributes).tap do |resource|
        if invite.present?
          permission_ids += invite.gallery.read_permissions.map(&:id)
          resource.email = invite.email if resource.email.blank?
        end

        PermissionsAssigner.new(account: account, resource: resource).process(role_ids, permission_ids)
      end
    end
end
