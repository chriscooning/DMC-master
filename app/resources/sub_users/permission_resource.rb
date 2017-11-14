class SubUsers::PermissionResource < SubUsers::BaseResource
  decorator SubUsers::BaseDecorator

  accessible_attributes :organization, :location, role_ids: [], permission_ids: []

  def edit
    edit! do |resource|
      authorize_resource!('read', resource)
    end
  end

  def build_collection
    scope = resource_scope
    if params[:search].try(:[], :query).present?
      scope = search_scope(scope, params[:search][:query])
    end
    scope.page(params[:page]).per(params[:per])
  end

  # we don't delete, just remove all permissions in current account scope
  def delete_resource(resource)
    if resource.blank? || resource.account_owner?(account)
      # do nothing, we can't delete owner
    else
      PermissionsAssigner.new(account: account, resource: resource).process([], [])
      resource.account_users.where(account_id: account.id, owner: false).destroy_all
    end
  end

  private

    def search_scope(base_scope, query)
      query.downcase!
      base_scope = 
        base_scope.where("lower(email) like ? OR lower(full_name) LIKE ? OR lower(location) LIKE ? OR lower(organization) LIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
      base_scope
    end

    def build_resource(id, attributes = {})
      # we should process role&permissions inside current account scope only
      role_ids        = attributes.delete(:role_ids) || []
      permission_ids  = attributes.delete(:permission_ids) || []

      super(id, attributes).tap do |resource|
        PermissionsAssigner.new(account: account, resource: resource).process(role_ids, permission_ids)
      end
    end
end
