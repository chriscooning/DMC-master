class Api::V1::GalleriesController < Api::V1::BaseController

  def index
    respond_with resource.read_all
  end

  private

    def resource
      @resource ||= Api::Galleries::MyResource.new(as: current_user)
    end
end
