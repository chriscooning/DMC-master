class InvitationMailer < ActionMailer::Base
  default from: configatron.noreply

  def new_admin_welcome_email(requests, inviter, user)
    @invites = requests
    email = requests.first.email
    @invitation_hash = requests.first.invitation_hash
    mail(to: email, subject: "[DMC] You were invited to system as an admin!")
  end

  def new_viewer_welcome_email(requests, inviter, user)
    @invites = requests
    email = requests.first.email
    @user_host = inviter.try(:host)
    @invitation_hash = requests.first.invitation_hash
    mail(to: email, subject: "[DMC] You were invited to system as a viewer!")
  end

  def registered_admin_welcome_email(requests, inviter, user)
    @invites = requests
    @user_host = inviter.try(:subdomain)
    mail(to: user.email, subject: "[DMC] You were invited to system as an admin!")
  end

  def registered_viewer_welcome_email(requests, inviter, user)
    @invites = requests
    email = user.email
    @user_host = inviter.try(:host)
    mail(to: user.email, subject: "[DMC] You were invited to system as a viewer!")
  end

  def recovery_email(gallery, invite)
    @invite = invite
    @gallery = gallery
    @user_host = gallery.account.try(:host)
    mail(to: @invite.email, subject: "[DMC] Your invitation link")
  end
end
