class Api::V1::InvitesController < Api::V1::BaseController

  def index
    respond_with {}
  end

  def create
    params.merge!(role: 'viewer')
    if service.invite
      render json: service.result_for_api
    else
      render json: { message: service.message }, status: 400
    end
  end

  def destroy
    service.destroy_invitation_by_email
    render json: { message: service.message }, status: service.status
  end

  private

    def service
      @service ||= GalleryInviter.new(as: current_user, params: params, send_email: false)
    end
end