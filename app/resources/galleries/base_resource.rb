class Galleries::BaseResource < Cyrax::Resource
  include Authentication::ResourceHelper

  resource :gallery

  def resource_scope
    account.galleries.visible.order('position ASC')
  end

  def read(id = nil)
    resource = find_resource(id || params[:id])
    authorize_resource!(:read, resource)
    assign_resource :folders, available_folders(resource)
    respond_with resource
  end

  def read_first_gallery
    read(first_gallery_id)
  end

  def has_first_gallery?
    first_gallery_id.present?
  end

  def read_portal
    authenticate!(account)
    announcements = account.announcements.page(1).per(configatron.pagination.announcements.per)
    assign_resource :announcements, announcements
    respond_with build_collection, name: collection_name, present: :collection
  end

  def build_collection
    authenticate!(account)
    resource_scope.order('featured DESC').select do |resource|
      resource.visible? || authorization_service.authorized?('read', resource)
    end
  end

  private

    def account
      @account ||= @options[:account]
    end

    def first_gallery_id
      @first_id ||= resource_scope.where(show_first: true).pluck(:id).first
    end

    def authorize_resource!(action, resource)
      authenticate!(account)
      return true if action.to_sym == :read_all
      raise ActiveRecord::RecordNotFound if resource.hidden?

      return true if resource.public?
      return true if resource.enable_password? && !!resource.authorized_keys.exists?(key: auth_hash)

      if !authorization_service.authorized?(action, resource)
        # if user haven't permissions, possible we can throw more detailed info
        authenticate!(resource)
        # NOTE: not place for this, autenticate method should be moved to auth service somehow
        raise Errors::AuthorizationRequired.new('authorization required', resource: resource)
      end
      true
    end

    def authorization_service
      Authorizers::Frontend.new(account: account, accessor: accessor)
    end

    def available_folders(gallery)
      gallery.folders.visible.select do |folder|
        !folder.hidden? || authorization_service.authorized?('read', folder)
      end
    end
end
