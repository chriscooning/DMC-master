ActiveAdmin.register Account do
  menu priority: 1
  filter :subdomain

  actions :all, :except => [:new, :create, :destroy]

  index do
    column :id
    column :subdomain, sortable: :subdomain do |account|
      subdomain = account.subdomain
      if Rails.env.development?
        url = [subdomain, request.host_with_port].compact.join('.')
      else
        url =[subdomain, configatron.host].compact.join('.')
      end
      link_to subdomain, url, target: '_blank'
    end
    column :owner do |account|
      if account.owner
        link_to "#{ account.owner.full_name } ( #{account.owner.email })", admin_user_path(account.owner)
      else
        'none'
      end
    end
    column :users, sortable: :account_users_count do |account|
      link_to account.users.count, admin_users_path(q: { account_users_account_id_eq: account.id })
    end
    column :created_at
    column :last_sign_in_at
    actions defaults: true do |account|
      if account.owner
        link_to "Become an owner", become_admin_user_path(account.owner)
      end
    end
  end
end
