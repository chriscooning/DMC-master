class Folders::MyResource < Cyrax::Resource
  resource :folder
  accessible_attributes :name, :hide_folder, :position, :password,
                        :hide_title, :hide_description, :enable_password, :gallery_id,
                        :default_per_page
  decorator Folders::MyDecorator

  def read_all
    scope = gallery.present? ? gallery.folders : account.folders
    collection = scope.select do |folder|
      authorization_service.authorized?('read', folder)
    end
    respond_with collection, name: collection_name, present: :collection
  end

  def resource_scope
    raise Errors::AuthorizationRequired if accessor.blank?

    base_scope = gallery.folders
    unless accessor.account_owner?(account)
      base_scope = base_scope.where(id: readable_resource_ids)
    end
    base_scope.order('position ASC')
  end

  def build_resource(id, attributes = {})
    super(id, attributes).tap do |folder|
      if folder.password.present?
        folder.encrypted_password = ::BCrypt::Password.create("#{folder.password}#{Folder.pepper}", cost: 1)
      end
      if id.present? && folder.gallery_id_changed?
        folder.gallery = new_gallery
        folder.position = 0
      end
      if folder.position == 0
        folder.position = gallery.folders.maximum(:position).to_i + 1
      end
    end
  end

  def create
    create! do |folder|
      # NOTE: heavy permissions management
      folder.create_permissions
      accessor.permissions << folder.permissions

      # assign read permissions on this element to all primary users
      folder.account.primary_users.each do |primary_user|
        primary_user.permissions << folder.permissions.where(action: 'read')
      end
    end
  end

  def update
    update! do |folder|
      clean_up_passwords(folder)
    end
  end

  def gallery
    @gallery ||= account.galleries.where(id: params[:gallery_id]).first
  end

  def new_gallery
    @new_gallery = account.galleries.where(id: resource_attributes[:gallery_id]).first
  end

  def reorder
    params[:order] ||= {}
    folders = gallery.folders.where(id: params[:order].keys)
    authorize_resource!(:sort_folders, gallery)
    transaction do
      folders.each { |folder| folder.update_column(:position, params[:order][folder.id.to_s]) }
    end
  end

  def delete_resource(resource)
    resource.delete
  end

  private

    def clean_up_passwords(folder)
      folder.password = nil
    end

    def account
      @account ||= @options[:account]
    end

    def authorization_service
      Authorizers::Backend.new(account: account, accessor: accessor)
    end

    def readable_resource_ids
      gallery.folders.collect do |folder|
        authorization_service.authorized?('read', folder) ? folder.id : nil
      end.compact
    end

    def authorize_resource!(action, resource)
      authorization_service.authorize!(action, resource)
    end
end
