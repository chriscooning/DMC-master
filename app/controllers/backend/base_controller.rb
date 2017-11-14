class Backend::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_password_expired!
  respond_to :html, :json, :csv

  rescue_from Errors::AuthorizationRequired do |exception|
    respond_to do |format|
      format.html {
        redirect_to dashboard_path, alert: I18n.t("alerts.not_authorized.page")
      }
      format.csv {
        redirect_to :back, alert: I18n.t("alerts.not_authorized.action")
      }
      format.json {
        render json: { code: exception.code }, status: 401
      }
    end
  end

  private

    def check_password_expired!
      if current_user.present? && current_user.password_expired?
        redirect_to profile_settings_path, alert: I18n.t('alerts.password_expired')
      end
    end

    def current_account
      @current_account ||= begin
        account = nil
        if params[:user_subdomain].present?
          account = current_user.accounts.where(subdomain: params[:subdomain]).first
        end
        if session[:current_account_id].present?
          account ||= current_user.accounts.where(id: session[:current_account_id]).first
        end
        account ||= current_user.primary_account
        session[:current_account_id] = account.id
        account
      end
    end

    def base_url
      subdomain = current_account.try(:subdomain)
      if Rails.env.development?
        "#{subdomain}.#{request.host_with_port}"
      else
        "#{subdomain}.#{configatron.host}"
      end
    end
    helper_method :base_url

    def backend?; true end

    def common_page?; false end
end
