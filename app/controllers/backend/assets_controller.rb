class Backend::AssetsController < Backend::BaseController
  respond_to :smil, only: :manifest

  def index
    respond_with resource.read_all
  end

  def show
    respond_with resource.read
  end

  def create
    render json: resource.create
  end

  def download
    redirect_to resource.download, status: 302
  end

  def update_multiple
    respond_with resource.update_multiple, location: nil
  end

  def update
    respond_with resource.update
  end

  def destroy
    respond_with resource.destroy
  end

  def manifest
    @asset = resource.read.result
    respond_to do |format|
      format.smil
    end
  end

  def generate_quicklink
    render json: { link: resource.generate_quicklink }
  end

  def reorder
    respond_with resource.reorder, location: nil
  end

  def sort
    respond_with resource.sort, location: nil
  end

  private
    def resource
      @resource ||= Assets::MyResource.new(as: current_user, account: current_account, params: params)
    end
end
