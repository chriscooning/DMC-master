class Backend::GalleriesController < Backend::BaseController
  def index
    respond_with resource.read_all
  end

  def show
    respond_with resource.read
  end

  def create
    respond_with resource.create
  end

  def edit
    respond_with resource.edit
  end

  def update
    respond_with resource.update
  end

  def destroy
    respond_with resource.destroy
  end

  def toggle_first
    respond_with resource.toggle_first
  end

  def reorder
    resource.reorder
    render text: 'ok'
  end

  def portal
    respond_with resource.read_portal
  end

  private

    def resource
      @my_resource ||= Galleries::MyResource.new(
        as: current_user,
        account: current_account,
        params: params
      )
    end
end
