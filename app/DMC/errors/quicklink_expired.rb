class Errors::QuicklinkExpired < Errors::Base
  def code
    'quicklink_expired'
  end

  def message
    'quicklink has been expired'
  end
end
