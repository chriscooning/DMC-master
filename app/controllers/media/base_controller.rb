class Media::BaseController < ApplicationController
  before_filter :authenticate_media_user!
  before_filter :parent_account
  respond_to :html, :json

  private

    def backend?; true end

    def common_page?; false end

    def parent_account
      @parent_account ||= User.find_by_subdomain!(params[:user_subdomain]) if params[:user_subdomain]
    end
    helper_method :parent_account

    def parent_account?
      parent_account.present?
    end
    helper_method :parent_account?

    def base_url
      subdomain = parent_account? ? parent_account.try(:subdomain) : current_account.try(:subdomain)
      if Rails.env.development?
        "#{subdomain}.#{request.host_with_port}"
      else
        "#{subdomain}.#{configatron.host}"
      end
    end
    helper_method :base_url
end
