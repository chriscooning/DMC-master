class Backend::AnnouncementsController < Backend::BaseController
  respond_to :js, only: :index

  def index
    respond_with resource.read_all
  end

  def new
    respond_with resource.build
  end

  def create
    respond_with resource.create, location: account_settings_path(anchor: 'portal')
  end

  def destroy
    # Figure out the referrer
    if request.referer.try(:include?, account_settings_path)
      referer = account_settings_path(anchor: 'portal')
    else
      referer = dashboard_path
    end

    respond_with resource.destroy, location: referer, notice: "Announcement succesfully deleted"
  end

  def edit
    respond_with resource.edit
  end

  def update
    respond_with resource.update, location: account_settings_path(anchor: 'portal')
  end

  private

    def resource
      @resoruce ||= Announcements::MyResource.new(account: current_account, as: current_user, params: params)
    end
end
