module Errors
  class PasswordRequired < StandardError
    attr_reader :resource

    def initialize(message, args = {})
      super(message)
      @resource = args[:resource]
    end

    def message
      'Please enter password'
    end

    def code
      'password_required'
    end
  end
end
