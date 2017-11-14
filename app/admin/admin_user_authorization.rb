class AdminUserAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    case subject
    when normalized(AdminUser)
      if action.to_sym == :read
        return true
      else
        if subject.instance_of?(AdminUser)
          subject.id == user.id || user.can_create_users?
        else
          user.can_create_users?
        end
      end
    else
      true
    end
  end
end
