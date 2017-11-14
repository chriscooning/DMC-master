class Api::TokenAuthorizer
  attr_reader :status, :errors, :result

  def intitialize
    @errors = []
  end

  def perform(method, params)
    params ||= {}
    @status = 200
    return if check_input!(params)
    user = find_and_authorize_user(params)
    send(method, user) if user
  end

  def create_token(user)
    token = Devise.friendly_token
    user.update_column :authentication_token, token
    @result = { token: token }
  end

  private

    def destroy_token(user)
    end

    def set_error(message)
      @result = { message: message }
    end

    def find_and_authorize_user(params)
      user = User.find_by_email(params[:email])
      return user if user && user.valid_password?(params[:password])
      @status = 401
      set_error('Wrong password or user not found')
      false
    end

    def check_input!(params)
      set_error('Password is mandatory param') if params[:password].nil?
      set_error('Email is mandatory param') if params[:email].nil?
      @status = 400 if params[:password].nil? || params[:email].nil?
    end

end