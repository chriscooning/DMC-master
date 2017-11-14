class Errors::QuicklinkInvalid < Errors::Base
  def code
    'quicklink_invalid'
  end

  def message
    'quicklink is invalid'
  end
end
