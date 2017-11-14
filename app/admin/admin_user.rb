ActiveAdmin.register AdminUser do
  actions :all

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  show do |user|
    panel "Details" do
      attributes_table_for user do
        row(:email)
        row(:password_expiration) do
          user.password_expired? ? 'already' : user.password_expire_at.to_s(:db)
        end
        row(:role) do
          user.can_create_users? ? 'superadmin' : 'admin'
        end
      end
    end

    panel "Sign in info" do
      attributes_table_for user do
        row(:sign_in_count)
        row(:current_sign_in_at)
        row(:current_sign_in_ip)
        row(:last_sign_in_at)
        row(:last_sign_in_ip)
      end
    end
  end

  filter :email

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      if (f.object == current_admin_user || current_admin_user.can_create_users?)
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end
  controller do
    skip_before_filter :check_admin_password_expired, only: [:show, :edit, :update, :destroy]

    def update
      if params[:admin_user].present?
        if params[:admin_user][:password].blank?
          params[:admin_user].delete(:password)
          params[:admin_user].delete(:password_confirmation)
        end
      end

      update!
    end

    def permitted_params
      admin_user_params = [:email, :password, :password_confirmation]
      params.permit :utf8, :authenticity_token, :commit, :id, :_method, admin_user: admin_user_params
    end
  end
end
