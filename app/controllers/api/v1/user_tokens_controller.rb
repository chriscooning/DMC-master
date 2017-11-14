class Api::V1::UserTokensController < Api::V1::BaseController
  skip_before_filter :authenticate_user_by_token_or_user_token!
  before_filter :authenticate_user_by_token!

  def create
    # authorization_token
    # or some keys

    #respond_with resource.create
    result = resource.create
    render json: { token: result.token, expire_at: result.expire_at }, status: :ok
  end

  # refresh token?
  #def update
  #end

  private

    def resource
      Api::UserTokens::BaseResource.new(as: current_user)
    end
end
