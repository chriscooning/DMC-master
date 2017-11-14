class BaseAuthenticator
  attr_accessor :account, :params

  def initialize(options = {})
    @account = options[:account]
    @params = options[:params]
  end

  def authenticate!(hash)
    if resource.valid_password?(params[:password])
      authorize!(hash)
      { result: 'ok' }
    else
      { errors: { password: "Wrong password!" } }
    end
  end

  private

    def resource
      raise "Please define resource"
    end

    def authorize!(hash)
      resource.authorized_keys.create(key: hash)
    end
end
