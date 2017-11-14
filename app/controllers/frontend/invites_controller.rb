class Frontend::InvitesController < Frontend::BaseController
  respond_to :html

  def new
    respond_with resource.build
  end

  def create
    respond_with resource.create, location: portal_root_path
  end

  private

    def resource
      InvitationRequests::BaseResource.new(
        as: current_user,
        account: current_account,
        params: params
      )
    end
=begin
  def recover
  end

  def submit
    if service.recover_invitation_link
      redirect_to portal_root_path, service.flashes
    else
      flash[:alert] = service.flashes[:alert]
      render :recover
    end
  end

  private

    def service
      @service ||= InvitationRecover.new(params: params)
    end
=end
end
