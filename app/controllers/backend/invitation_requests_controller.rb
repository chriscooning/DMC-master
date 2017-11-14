class Backend::InvitationRequestsController < Backend::BaseController

  def destroy
    respond_with resource.destroy, location: security_settings_path(anchor: 'invitations')
  end

  private

    def resource
      @resource ||= InvitationRequests::MyResource.new(as: current_user, account: current_account, params: params)
    end

    #def resource
    #  @resource ||= Invites::MyRequestResource.new(as: current_user, params: params)
    #end
end
