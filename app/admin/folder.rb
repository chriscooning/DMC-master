ActiveAdmin.register Folder do

  scope :all, default: true
  scope :deleted

  filter :name
  filter :gallery_id, label: 'Gallery', as: :select,
    collection: proc { Gallery.order('name asc').map{|a| [a.name, a.id] }}

  actions :index, :show, :destroy

  index do
    column :id
    column :name
    column :account
    column :created_at
    actions default: true do |f|
      link_to "Restore", restore_admin_folder_path(f) if f.deleted?
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :gallery
      row :account
      row :hide_folder
      row(:password_enabled) { |f| f.enable_password? }
      row :hide_title
      row :hide_description
      row :created_at
    end
  end

  member_action :restore do
    find_resource.restore!
    redirect_to admin_folders_path, notice: 'Folder was restored!'
  end

  controller do
    def find_resource
      resource_class.with_deleted.find(params[:id])
    end
  end
end
