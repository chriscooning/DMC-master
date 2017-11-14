module Errors
  class MediaAuthorizationRequired < StandardError
    def message
      'Only authorized media can access this gallery'
    end

    def code
      'media_authorization_required'
    end
  end
end