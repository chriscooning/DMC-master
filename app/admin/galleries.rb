ActiveAdmin.register Gallery do
  filter :name
  filter :user_id

  filter :account_id, label: 'Account', as: :select,
    collection: proc { Account.order('subdomain asc').map{|a| [a.subdomain, a.id] }}

  scope :all, default: true
  scope :deleted

  actions :index, :show, :destroy

  index do
    column :id
    column :name
    column :user
    column :visible
    column :created_at
    actions default: true do |g|
      link_to "Restore", restore_admin_gallery_path(g) if g.deleted?
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :user
      row :gallery_message
      row :restrictions_message
      row :help_message
      row :visible
      row :created_at
      row(:password_enabled) { |g| g.enable_password? }
      row(:invitation_credentials_enabled) { |g| g.enable_invitation_credentials? }
    end    
  end

  member_action :restore do
    find_resource.restore!
    redirect_to admin_galleries_path, notice: 'Gallery was restored!'
  end

  controller do
    def find_resource
      resource_class.with_deleted.find(params[:id])
    end

    def scoped_collection
      resource_class.includes(:user)
    end
  end
end
