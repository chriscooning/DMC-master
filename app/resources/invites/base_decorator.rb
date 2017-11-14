class Invites::BaseDecorator < Cyrax::Decorator
  include Rails.application.routes.url_helpers

  def account
    @account ||= resource.gallery.try(:account)
  end

  def gallery_path
    if account.present?
      super(resource.gallery_id, user_subdomain: account.try(:subdomain))
    else
      super(resource.gallery_id)
    end
  end

  def sender
    resource.gallery.account.owner
  rescue
    nil
  end

  def sender_full_name
    sender.try(:full_name)
  end

  def user_name
    sender.try(:full_name)
  end

  def user_email
    sender.try(:email)
  end

  def gallery_name
    gallery.try(:name)
  end

  def owner_subdomain
    @account.try(:subdomain)
  end

  def last_login_display
    #user.last_sign_in_at ? I18n.l(user.last_sign_in_at, format: :display) : '-'
  end
end
