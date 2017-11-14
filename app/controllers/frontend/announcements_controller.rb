class Frontend::AnnouncementsController < Frontend::BaseController
  respond_to :js

  def index
    respond_with resource.read_all
  end

  private

    def resource
      @resource ||= Announcements::BaseResource.new(as: current_account, params: params)
    end
end
