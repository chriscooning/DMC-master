class Frontend::AuthorizationsController < Frontend::BaseController
  # subdomain password authorizer
  def password
    service = SubdomainAuthenticator.new(account: current_account, params: params)
    render json: service.authenticate!(media_authorization_token)
  end
end
