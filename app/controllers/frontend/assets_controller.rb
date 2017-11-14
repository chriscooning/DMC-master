class Frontend::AssetsController < Frontend::BaseController
  respond_to :json, only: :index
  respond_to :smil, only: [:manifest, :quick_link_manifest]
  respond_to :html, only: [:quicklink, :embedded]
  before_filter :save_invitation_token

  rescue_from Errors::InviteAuthorizationRequired do |exception|
    render json: { code: exception.code }, status: 401
  end

  rescue_from Errors::PasswordRequired do |exception|
    respond_to do |format|
      format.json {
        render json: { code: exception.code }, status: 401
      }
      format.html {
        if exception.resource && exception.resource.is_a?(User)
          render template: 'frontend/authorizations/password', locals: { desired_link: request.path }
        else
          link = galleries_path(ask_password_for: exception.resource.id)
          redirect_to link, alert: exception.message
        end
      }
    end
  end

  rescue_from Errors::QuicklinkExpired, Errors::QuicklinkInvalid do |exception|
    respond_to do |format|
      format.html {
        redirect_to root_path, alert: I18n.t("api.errors.assets.#{ exception.code }")
      }
      format.json {
        render json: { code: exception.code }, status: 404
      }
    end
  end

  def index
    respond_with resource.read_all
  end

  def quicklink
    respond_with resource.read_quicklink
  end

  def manifest
    @asset = resource.read.result
    respond_to do |format|
      format.smil
    end
  end

  def quicklink_manifest
    @asset = resource.read_quicklink.result
    render :manifest
  end

  def download
    redirect_to resource.download, status: 302
  end

  def quicklink_download
    redirect_to resource.download_quicklink, status: 302
  end

  def embedded
    response.headers['X-Frame-Options'] = ''
    respond_with resource.read_embedded, layout: 'iframe'
  end

  def embedded_manifest
    @asset = resource.read_embedded.result
    render :manifest
  end

  private

    def resource
      @resource ||= Assets::BaseResource.new(
        as: current_user,
        account: current_account,
        params: params,
        auth_hash: media_authorization_token
      )
    end
end
