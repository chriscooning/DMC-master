class Media::AuthorizationsController < Media::BaseController

  def index
    respond_with resource.read_all
  end

  def create
    respond_with resource.create, location: nil
  end

  def destroy
    respond_with resource.destroy, location: media_dashboard_path
  end

  private

    def resource
      @resource ||= MediaAuthorizations::MediaResource.new(
        as: current_media_user, 
        params: params
      )
    end
end
