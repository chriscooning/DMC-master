class Users::BaseDecorator < Cyrax::Decorator
  include Rails.application.routes.url_helpers
  
  def as_json(options = {})
    only = [:email, :full_name, :password, :password_confirmation]
    method = []
    resource.as_json(methods: methods, only: only)
  end
end
