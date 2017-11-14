class Backend::InvitesController < Backend::BaseController

  def index
    respond_with resource.read_all
  end

  def my
    resource = Invites::MyMembershipResource.new(as: current_user, params: params)
    respond_with resource.read_all
  end

  def new
    respond_with resource.build
  end

  def create
    result = service.invite
    if result
      redirect_to security_settings_path(anchor: 'invites'), notice: "Invite(s) created"
    else
      redirect_to new_invite_path, alert: service.message
    end
  end

  def destroy
    respond_with resource.destroy, location: security_settings_path(anchor: 'invites')
  end

  private

    def resource
      @resource ||= Invites::MyMemberResource.new(as: current_user, params: params)
    end

    def service
      @service ||= GalleryInviter.new(as: current_user, account: current_account, params: params)
    end
end
