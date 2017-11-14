ActiveAdmin.register User do
  menu priority: 1
  filter :email
  filter :full_name
  filter :account_users_account_id, label: 'Account', as: :select,
    collection: proc { Account.order('subdomain asc').map{|a| [a.subdomain, a.id] }}

  filter :created_at

  index do
    column :id
    column :email
    column :full_name
    column :subdomain do |user|
      subdomain = user.primary_account.try(:subdomain)
      if Rails.env.development?
        url = [subdomain, request.host_with_port].compact.join('.')
      else
        url =[subdomain, configatron.host].compact.join('.')
      end 
      link_to subdomain, url, target: '_blank'
    end

    column :created_at
    column :last_sign_in_at
    column :favorite do |user|
      if current_admin_user.favorite?(user)
        link_to 'Remove from favorites', toggle_favorite_admin_user_path(user)
      else
        link_to 'Add to favorites', toggle_favorite_admin_user_path(user)
      end
    end

    actions defaults: true do |user|
      link_to "Become", become_admin_user_path(user)
    end
  end

  show do
    panel "User Details" do
      attributes_table_for user do
        row(:email)
        row(:full_name)
        row(:subdomain)
        row(:created_at)
      end
    end
    panel 'Additional information' do
      attributes_table_for user do
        row(:sign_in_count)
        row(:current_sign_in_at)
        row(:last_sign_in_at)
        row(:current_sign_in_ip)
        row(:last_sign_in_ip)
        row(:password_expired) do |resource|
          resource.password_expired ? 'Request to change password has been sent' : ''
        end
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs "Details" do
      f.input :email
      f.input :full_name
      if f.object.new_record?
        f.input :subdomain
        f.input :password
      end
      f.input :skip_confirmation, label: 'Skip confirmation', as: :boolean
      f.input :password_expired, label: 'Request password change on next login'
    end
    f.actions
  end

  member_action :become do
    sign_in(:user, User.find(params[:id]))
    redirect_to dashboard_path
  end

  member_action :toggle_favorite do
    current_admin_user.toggle_favorite_user(params[:id])
    redirect_to admin_users_path
  end

  controller do
    def create
      response = Users::AdminResource.new(as: current_admin_user, params: params).create
      @user = response.result
      create!
    end

    def update
      response = Users::AdminResource.new(as: current_admin_user, params: params).update
      @user = response.result
      update!
    end

    def permitted_params
      user_params = [:email, :full_name, :password_expired, :subdomain, :password, :skip_confirmation]
      params.permit :utf8, :authenticity_token, :commit, user: user_params
    end
  end
end
