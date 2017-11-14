class Backend::AuthorizationsController < Backend::BaseController

  def index
    respond_with resource.read_all
  end

  def approve
    #respond_with resource.approve, location: authorizations_path
    respond_with resource.approve, location: security_settings_path
  end

  def decline
    #respond_with resource.decline, location: authorizations_path
    respond_with resource.decline, location: security_settings_path
  end

  private

    def resource
      @resource ||= MediaAuthorizations::OwnerResource.new(as: current_user, params: params)
    end
end
