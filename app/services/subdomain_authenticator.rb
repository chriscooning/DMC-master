class SubdomainAuthenticator < BaseAuthenticator
  def authenticate!(hash)
    if resource.valid_subdomain_password?(params[:password])
      authorize!(hash)
      { result: 'ok' }
    else
      { errors: { password: "Wrong password!" } }
    end
  end

  private

    def resource
      @resource ||= account
    end
end
