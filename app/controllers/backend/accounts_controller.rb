class Backend::AccountsController < Backend::BaseController
  def update
    respond_with resource.update, location: account_settings_path
  end

  def retrieve_auth_token
    render json: ::Api::TokenAuthorizer.new.create_token(current_user)
  end

  private

    def resource
      @resource ||= Accounts::MyResource.new(as: current_user, account: current_account, params: params)
    end
end
