class Users::AuthDecorator < Users::BaseDecorator
  def permissions
    @permissions ||= resource.present? ? resource.permissions.for_account(account) : []
  end

  def has_permission_to?(action_name)
    return false if resource.blank?
    return true if resource.account_owner?(account)

    permissions.select{|i| i.action == action_name }.present?
  end

  def can_create_assets?
    has_permission_to?('create_assets')
  end

  def can_view_analytics?
    @can_view_analytics ||= authorization_service.authorized?(:view_analytics, account)
  end

  def can_view_account?
    @can_view_account ||= authorization_service.authorized?(:read, account)
  end

  def can_edit_account?
    @_can_edit_account ||= authorization_service.authorized?(:edit, account)
  end

  def can_view_subaccounts?
    @_can_view_subaccounts ||= authorization_service.authorized?(:view_subaccounts, account)
  end

  def can_edit_subaccounts?
    @_can_edit_subaccounts ||= authorization_service.authorized?(:edit_subaccounts, account)
  end

  def can_edit_security?
    resource.present? && resource.account_owner?(account)
  end

  def can_edit_announcements?
    #authorization_service.authorized?(:edit_subaccounts, account)
    can_edit_account?
  end

  def can_edit_gallery?(gallery)
    authorization_service.authorized?(:edit, gallery)
  end

  def can_add_gallery?
    @_can_add_gallery ||= authorization_service.authorized?('create_galleries', account)
  end

  def other_accounts
    return [] if resource.blank?
    @other_accounts ||= begin
      resource.accounts.to_a.uniq.select { |acc| acc.id != account.id }
    end
  end

  private

  def account
    options[:account]
  end

  def authorization_service
    @authorization_service ||= Authorizers::Backend.new(account: account, accessor: resource)
  end
end
