class SubUsers::BaseDecorator < Cyrax::Decorator
  include Rails.application.routes.url_helpers

  def as_json(options = {})
    only = [:email, :full_name, :password, :password_confirmation]
    method = []
    resource.as_json(methods: methods, only: only)
  end

  def available_roles
    @available_roles ||= options[:account].roles.includes(:permissions)
  end

  def available_roles_json
    result = {}
    available_roles.each do |role|
      result[role.id] = role.permissions.map{|p| { id: p.id, action: p.action }}
    end
    result.to_json
  end

  def role_name
    names = self.roles.where('roles.account_id = ?', options[:account].id).map(&:name)
    names.present? ? names.join(', ') : 'None Assigned'
  end

  def last_login_at
    last_sign_in_at.present? ? last_sign_in_at.strftime("%m/%d/%Y") : 'never'
  end

  def invited?
    @_is_invited_user ||= !!AccountUser.where(
      user_id: self.id,
      account_id: options[:account].id,
      invited: true
    ).exists?
  end

  def account_primary?
    @_is_account_primary ||= !!AccountUser.where(
      user_id: self.id,
      account_id: options[:account].id,
      primary: true
    ).exists?
  end
end
