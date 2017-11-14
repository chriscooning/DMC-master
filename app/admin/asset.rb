ActiveAdmin.register Asset do 
  remove_filter :folder
  remove_filter :account
  remove_filter :taggings
  remove_filter :base_tags
  remove_filter :tags
  remove_filter :tag_taggings


  scope :all, default: true
  scope :deleted

  index do
    column :id
    column :title
    column :account
    column :created_at
    actions default: true do |asset|
      link_to 'Restore', restore_admin_asset_path(asset) if asset.deleted?
    end
  end

  show do
    attributes_table do
      row :id
      row :title
      row :folder
      row :account
      row :downloadable
      row("Tag list") { |a| a.cached_tag_list }
      row :created_at
      row :processed
      row "View" do |a|
        render("item", resource: a)
      end
    end
  end

  member_action :restore do
    asset = Asset.deleted.find(params[:id])
    asset.restore!
    redirect_to admin_assets_path, notice: 'Asset was restored!'
  end

  actions :index, :show, :destroy

  controller do
    def find_resource
      resource_class.with_deleted.find(params[:id])
    end

    def scoped_collection
      resource_class.includes(:account)
    end
  end
end
