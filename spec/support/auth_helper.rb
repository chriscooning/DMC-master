module AuthHelper
  def http_login
    user = configatron.http_pasw.username
    pw = configatron.http_pasw.password
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end  
end