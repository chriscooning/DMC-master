# sub-users management
class Backend::UsersController < Backend::BaseController
  def index
    respond_with permission_resource.read_all
  end

  def new
    respond_with resource.build
  end

  def create
    respond_with resource.create, location: account_users_path
  end

  def invite
    respond_with invitation_resource.build
  end

  def create_invited
    respond_with invitation_resource.create, location: account_users_path
  end

  def edit
    respond_with permission_resource.edit
  end

  def update
    respond_with permission_resource.update, location: account_users_path
  end

  def destroy
    respond_with permission_resource.destroy, location: account_users_path
  end

  def members_csv
    set_resource_from(permission_resource.read_all)
    send_data(
      csv_service.export("members", @users),
      type: 'text/csv; charset=utf-8; header=present', filename: "members-#{DateTime.now}.csv"
    )
  end

  private

    def csv_service
      CsvExporter.new
    end

    # create new user
    def resource
      @resource ||= SubUsers::MyResource.new(
        as: current_user,
        account: current_account,
        params: params
      )
    end

    # manage sub user access
    def permission_resource
      @permission_resource ||= SubUsers::PermissionResource.new(
        as: current_user,
        account: current_account,
        params: params
      )
    end

    # add already existed user
    def invitation_resource
      @invitation_resource ||= SubUsers::InvitationResource.new(
        as: current_user,
        account: current_account,
        params: params
      )
    end
end
