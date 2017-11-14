module Authentication
  module ResourceHelper
    
    extend ActiveSupport::Concern

    included do
      attr_accessor :auth_hash, :user
    end

    def initialize(options = {})
      super
      @auth_hash = options[:auth_hash]
      @user = options[:user]
    end

    private

      def authenticate!(resource)
        unless resource.password_authorized?(auth_hash)
          raise Errors::PasswordRequired.new('Password Required', resource: resource)
        end
        # access to resource managed by authorization service
        if resource.invitations_requests_enabled?
          raise Errors::InviteAuthorizationRequired
        end
        #raise ActionController::RoutingError.new('Not Found') if !resource.protected? && resource.hidden?
        raise ActiveRecord::RecordNotFound if !resource.protected? && resource.hidden?
        resource
      end
  end
end
