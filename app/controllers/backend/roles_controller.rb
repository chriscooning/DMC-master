class Backend::RolesController < Backend::BaseController
  def index
    respond_with resource.read_all
  end

  def new
    respond_with resource.build
  end

  def create
    respond_with resource.create, location: account_roles_path
  end

  def edit
    respond_with resource.edit
  end

  def update
    respond_with resource.update, location: account_roles_path
  end

  def destroy
    respond_with resource.destroy, location: account_roles_path
  end

  private

    def resource
      @resource ||= Roles::BaseResource.new(as: current_user, account: current_account, params: params)
    end
end
