class PermissionsAssigner
  attr_accessor :account, :resource

  #PermissionsAssigner.new(account: account, resource: resource).process(role_ids, permission_ids)

  def initialize(account: nil, resource: nil)
    raise Errors::AuthorizationRequired if account.blank?
    raise Errors::AuthorizationRequired if resource.blank?
    @account  = account
    @resource = resource
  end

  def process(role_ids, permission_ids)
    assign_roles(role_ids) if !role_ids.nil?
    assign_permissions(permission_ids) if !permission_ids.nil?
    #resource.save if !(role_ids.nil? && permission_ids.nil?)
    resource
  end

  private

    def assign_roles(role_ids)
      roles_from_other_accounts = resource.roles.where('roles.account_id != ?', account.id).map(&:id)
      roles_for_this_account    = account.roles.where(id: role_ids).map(&:id)

      resource.role_ids = (roles_from_other_accounts + roles_for_this_account).flatten
    end

    def assign_permissions(permission_ids)
      permissions_from_other_accounts = resource.permissions.where('permissions.account_id != ?', account.id).map(&:id)
      permissions_for_this_account    = account.permissions.where(id: permission_ids).map(&:id)

      resource.permission_ids = (permissions_from_other_accounts + permissions_for_this_account).flatten
    end
end
