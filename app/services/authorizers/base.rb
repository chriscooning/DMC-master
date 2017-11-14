class Authorizers::Base
  attr_accessor :account, :accessor

  def initialize(account: nil, accessor: nil)
    raise Errors::AuthorizationRequired if account.blank?
    @account  = account
    @accessor = accessor
  end

  def authorize!(action, resource)
    unless authorized?(action, resource)
      raise Errors::AuthorizationRequired.new('authorization required', resource: resource)
    end
    return true
  end

  def authorized?(action, resource)
    #return false  if resource.blank?
    return true   if accessor.present? && accessor.account_owner?(account)
    return false  if accessor.blank? && accessor_required?
    # for access 'index' page we have separate permission 
    #   or we can check each item in collection to 'read'
    return true  if action.to_sym == :read_all
    
    return case action.to_sym
    when :read
      return true if resource.respond_to?(:public?) && resource.public? && show_visible_items_for_all?
      user_have_permission?(:read, resource) || user_role_have_permission?(:read, resource)
    when :create
      user_have_permission?(:create, resource) || user_role_have_permission?(:create, resource)
    when :build, :edit, :destroy, :update
      user_have_permission?(:edit, resource) || user_role_have_permission?(:edit, resource)
    when :view_analytics
      user_have_permission?(:view_analytics, account) || user_role_have_permission?(:view_analytics, account)
    else
      user_have_permission?(action.to_sym, resource) || user_role_have_permission?(action.to_sym, resource)
    end
  end

  def accessor_required?
    false
  end

  # strict mode?
  def show_visible_items_for_all?
    true
  end

  def user_have_permission?(action, resource)
    accessor.present? && have_permission?(accessor, action, resource)
  end

  def user_role_have_permission?(action, resource)
    accessor.present? && accessor.roles.present? && accessor.roles.any?{|role| have_permission?(role, action, resource)}
  end

  private

  def have_permission?(owner, action, resource)
    if action.to_sym == :create
      if resource.is_a?(Gallery)
        owner.permissions.where(action: 'create_galleries').exists?.present?
      elsif resource.is_a?(Folder)
        owner.permissions.where(action: 'create_folders').exists?.present?
      else
        false
      end
    else
      base_scope = owner.permissions.where(resource: resource)
      if action.to_sym != :read
        base_scope = base_scope.where(action: action.to_s)
      end
      base_scope.exists?.present?
    end
  end
end
