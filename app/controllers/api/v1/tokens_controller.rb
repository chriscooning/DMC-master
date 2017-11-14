# NOTE
# user should be able to get token only via UI. 
# left this only for backward compability
# token => user_token [ temporarily ]
#
class Api::V1::TokensController < Api::V1::BaseController
  skip_before_filter :authenticate_user_by_token!
  skip_before_filter :authenticate_user_by_token_or_user_token!
  
  def create
    service.perform(:create_token, params)
    render json: service.result, status: service.status
  end

  def destroy
    service.destroy_token(params)
    render json: service.result, status: service.status
  end

  private

    def service
      @service ||= Api::TokenAuthorizer.new
    end
end
