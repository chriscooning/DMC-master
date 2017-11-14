class Errors::AuthorizationRequired < Errors::Base
  attr_reader :resource

  def initialize(message = nil, args = {})
    message ||= default_message
    super(message)
    @resource = args[:resource]
  end

  def default_message
    'Only authorized users can do this'
  end

  def code
    'authorization_required'
  end
end
