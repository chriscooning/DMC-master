class Api::BaseResource < ::Cyrax::Resource
  private

  def require_record(classname, &block)
    begin
      block.call
    rescue ::ActiveRecord::RecordNotFound => e
      raise ::Errors::NotFound.new(classname)
    end
  end
end