module Errors
  class InviteAuthorizationRequired < StandardError
    def message
      'Only invited users can access this gallery'
    end

    def code
      'invite_authorization_required'
    end
  end
end