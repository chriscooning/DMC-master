class Backend::DownloadsController < Backend::BaseController
  respond_to :js, only: :index

  def index
    respond_with resource.read_all
  end

  def detailed
    respond_with resource.read_all
  end

  private

    def resource
      @resource ||= Downloads::MyResource.new(as: current_user, account: current_account, params: params)
    end
end