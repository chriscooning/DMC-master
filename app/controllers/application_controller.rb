class ApplicationController < ActionController::Base
  include Cyrax::ControllerHelper
  
  protect_from_forgery with: :exception
  before_filter :configure_devise_attributes, if: :devise_controller?
  before_filter :load_current_account  
  before_filter :http_authenticate

  # it should be current_user, but cyrax have problems with nested decorators.
  def accessor
    @accessor ||= Users::AuthDecorator.new(current_user, account: current_account)
  end
  helper_method :accessor

  private

    def load_current_account
      current_account
    end

    def current_account; end
    helper_method :current_account

    def show_registration_link?; true end
    helper_method :show_registration_link?

    def backend?; false end
    helper_method :backend?

    def frontend?; !backend? end
    helper_method :frontend?

    def landing_page?; false end
    helper_method :landing_page?

    def common_page?; true end
    helper_method :common_page?

    def configure_devise_attributes
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(Users::ProfileResource.accessible_attributes + [:invitation_hash, :subdomain])
      end
    end

    def save_invitation_token
      session[:invitation_hash] = params[:invitation_hash] if params[:invitation_hash].present?
    end

    def check_admin_password_expired
      return if devise_controller?
      if current_admin_user.present? && current_admin_user.password_expired?
        redirect_to edit_admin_admin_user_path(current_admin_user), alert: I18n.t('alerts.password_expired')
      end
    end

  protected

  def http_authenticate
    return unless configatron.http_pasw.enabled

    authenticate_or_request_with_http_basic do |username, password|
      username == configatron.http_pasw.username && password == configatron.http_pasw.password
    end
  end
end
