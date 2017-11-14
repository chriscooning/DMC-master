class Api::V1::FoldersController < Api::V1::BaseController
  
  rescue_from ActiveRecord::RecordNotFound do |e|
    error = params[:gallery_id].present? ? "not_found" : "no_gallery_id"
    code = params[:gallery_id].present? ? 404 : 400
    render json: { message: I18n.t("api.errors.folders.#{error}") }, status: code
  end

  def index
    respond_with resource.read_all
  end

  private

    def resource
      @resource ||= Api::Folders::MyResource.new(as: current_user, params: params)
    end  
end