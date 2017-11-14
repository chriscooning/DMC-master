class Backend::ProfilesController < Backend::BaseController
  skip_before_filter :check_password_expired!

  def update
    result = resource.update
    sign_in resource.find_resource(nil), bypass: true
    if result.success?
      respond_with result, location: profile_settings_path
    # TODO: find out reasons of strange cyrax behaviour
    else
      @user = result.result.resource
      render "backend/settings/profile"
    end
  end

  private

    def resource
      @resource ||= Users::ProfileResource.new(as: current_user, params: params)
    end
end
