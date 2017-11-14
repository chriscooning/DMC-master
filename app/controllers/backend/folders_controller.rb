class Backend::FoldersController < Backend::BaseController
  # /folders, or /galleries/:gallery_id/folders
  def index
    respond_with resource.read_all
  end

  def show
    respond_with resource.read
  end

  def create
    respond_with resource.create, location: nil
  end

  def update
    respond_with resource.update, location: nil
  end

  def destroy
    respond_with resource.destroy, location: nil
  end

  def reorder
    resource.reorder
    render text: 'ok'
  end

  private

    def resource
      @my_resource ||= Folders::MyResource.new(as: current_user, account: current_account, params: params)
    end
end
