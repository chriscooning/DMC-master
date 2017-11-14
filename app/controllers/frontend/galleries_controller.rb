class Frontend::GalleriesController < Frontend::BaseController
  respond_to :html
  before_filter :save_invitation_token, only: [:show, :first]

  rescue_from Errors::PasswordRequired do |exception|
    if exception.resource && exception.resource.is_a?(Account)
      render template: 'frontend/authorizations/password', locals: { desired_link: request.path }
    else
      link = galleries_path(ask_password_for: exception.resource.id)
      redirect_to link, alert: exception.message
    end
  end

  rescue_from Errors::InviteAuthorizationRequired do |exception|
    link = new_gallery_invitation_request_path(params[:id])
    redirect_to galleries_path, alert: I18n.t("alerts.invite_authorization", link: link)
  end

  rescue_from Errors::AuthorizationRequired do |exception|
    redirect_to new_user_session_path, alert: I18n.t("alerts.authorization_required")
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    if Rails.env.development?
      logger.debug("**** exception catched #{ exception.inspect }")
    end
    render template: 'frontend/not_found', status: 404
  end

  def portal
    if resource.has_first_gallery?
      respond_with resource.read_first_gallery, template: 'frontend/galleries/show'
    else
      respond_with resource.read_portal
    end
  end

  def index
    respond_with resource.read_all
  end

  def show
    respond_with resource.read
  end

  def authenticate
    render json: authentication_service.authenticate!(media_authorization_token)
  end

  private

    def authentication_service
      @authentication_service ||= GalleryAuthenticator.new(account: current_account, params: params)
    end

    def resource
      @resource ||= Galleries::BaseResource.new(
        as: current_user,
        account: current_account,
        params: params,
        auth_hash: media_authorization_token,
      )
    end
end
