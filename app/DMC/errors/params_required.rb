class Errors::ParamsRequired < Errors::Base
  attr_accessor :param_names

  def initialize(param_names)
    @param_names = param_names
  end
end