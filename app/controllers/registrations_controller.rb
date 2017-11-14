class RegistrationsController < Devise::RegistrationsController
  before_filter :save_invitation_token, only: :new

  def new
    build_resource({})
    self.resource.invitation_hash = session[:invitation_hash]
    respond_with self.resource
  end

  def create
    self.resource = RegistrationService.new(params, session).create_with_account

    if resource.persisted? # resource.save? resource.valid?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end 
    else
      clean_up_passwords resource
      respond_with resource, location: new_user_registration_path
    end
  end
end
