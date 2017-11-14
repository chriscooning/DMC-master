class Backend::EventsController < Backend::BaseController
  respond_to :js

  def index
    respond_with resource.read_all
  end

  private

    def resource
      @resource ||= Assets::ReportResource.new(as: current_user, account: current_account, params: params)
    end
end