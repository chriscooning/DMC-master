class InvitationRecover
  attr_accessor :params

  def initialize(options = {})
    @params = options[:params]
    @_errors = []
    @_notices = []
  end

  def recover_invitation_link
    @gallery = Gallery.find(params[:id])
    if invite = @gallery.invites.where(email: params[:email]).first
      InvitationMailer.recovery_email(@gallery, invite).deliver
      add_message(:notice, 'Email with invitation link sent!')
      true
    else
      add_message(:error, 'User with this email doesn\'t have invite to this gallery' )
      false
    end
  end

  def flashes
    flash = {}
    flash.merge!(notice: @_notices.join(' ')) if @_notices.any? 
    flash.merge!(alert: @_errors.join(' ')) if @_errors.any? 
    flash
  end

  private

    def add_message(type, message)
      case type.to_s
        when 'notice' then @_notices << message
        when 'error' then @_errors << message
      end
    end
end