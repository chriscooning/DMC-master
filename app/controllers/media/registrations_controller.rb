class Media::RegistrationsController < Devise::RegistrationsController

  private
  
    def configure_devise_attributes
      attributes = [:name, :phone, :email, :password, :password_confirmation, :outlet,
                    :terms_of_use, :circulation, :angle, :story_run_date]
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(attributes)
      end
    end
end