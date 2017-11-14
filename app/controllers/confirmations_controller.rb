class ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      if resource.sign_in_count == 0
        sign_in resource
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        respond_with_navigational(resource){ redirect_to root_url }
      else
        sign_out resource
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        respond_with_navigational(resource){ redirect_to root_url }
      end
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end
end
