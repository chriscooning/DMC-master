class Users::BaseResource < Cyrax::Resource
  decorator Users::BaseDecorator

  resource :user, class_name: "User"

  accessible_attributes :email, :full_name, :password, :password_confirmation
end
