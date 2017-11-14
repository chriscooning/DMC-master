class Frontend::BaseController < ApplicationController
  before_filter :load_current_account
  before_filter :set_authenticate_cookie
  layout 'subdomain'

  rescue_from Errors::InvalidSubdomain do |e|
    # redirect_to 'http://digitalmediacenter.com'
    redirect_to "#{ request.protocol }#{configatron.host}"
  end

  private

    def set_authenticate_cookie
      cookies[:authorization_cookie] ||= {
        value: SecureRandom.hex,
        expires: Time.now + configatron.media_authentication.duration
      }
    end

    def media_authorization_token
      cookies[:authorization_cookie]
    end
    helper_method :media_authorization_token

    def current_account
      @current_account ||= begin
        subdomain = request.subdomain.to_s.downcase
        subdomain.sub!('www.', '')
        if Rails.env.development?
          # here could be proxylocal url
          # like: subdomain.proxylocal_custom_domain.t.proxylocal.com
          subdomain = subdomain.split('.').first
        end
        Account.where(subdomain: subdomain).first || raise(Errors::InvalidSubdomain)
      end
    end

    def show_registration_link?; false end

    def common_page?; false end
end
