class Frontend::FoldersController < Frontend::BaseController
  respond_to :json
  
  def authenticate
    render json: resource.authenticate!(media_authorization_token)
  end

  private

    def resource
      @resource ||= FolderAuthenticator.new(account: current_account, params: params)
    end
end
