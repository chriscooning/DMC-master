class Errors::NotFound < Errors::Base
  attr_accessor :classname, :id

  def initialize(classname, id = nil)
    @classname = classname
    @id        = id
  end
end