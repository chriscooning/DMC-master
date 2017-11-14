class Api::UserTokens::BaseResource < Cyrax::Resource
  resource :user_token, class_name: "UserToken"
  serializer ::Api::UserTokens::BaseSerializer

  def create
    user_token = accessor.tokens.active.first

    if user_token.blank?
      user_token = accessor.tokens.create
      user_token.enable_at = Time.now
      user_token.expire_at = 1.hour.from_now
      user_token.save
    end

    #respond_with user_token
    user_token
  end

  private
end
