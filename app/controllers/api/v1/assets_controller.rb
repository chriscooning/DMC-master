class Api::V1::AssetsController < Api::V1::BaseController
  respond_to :smil, only: :manifest
  def index
    check_required_params(:gallery_id, :folder_id)
    respond_with resource.read_all
  end

  def manifest
    @asset = resource.read.result
    respond_to do |format|
      format.smil
    end
  end

  private

    def resource
      @resource ||= Api::Assets::MyResource.new(as: current_user, params: params)
    end
end