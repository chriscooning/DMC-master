class Assets::BaseResource < Cyrax::Resource
  include Authentication::ResourceHelper
  
  resource :asset
  decorator Assets::BaseDecorator

  def resource_scope
    folder.assets
  end

  def read_all
    result = build_collection
    decorated_result = Assets::BaseDecorator.decorate_collection(result)
    { result: decorated_result, total_count: result.total_count }
  end

  def build_collection
    scope = gallery.assets.where(folder_id: readable_folder_ids)
    if params[:query].present?
      scope = search_scope(scope, params[:query])
    end
    scope.processed.includes(:account).page(params[:page]).per(params[:per])
  end

  def read_quicklink
    respond_with find_resource_by_quicklink_hash!(params[:quicklink_hash])
  end

  def read_embedded
    resource = resource_class.find_by_embedding_hash!(params[:embedding_hash])
    #authorize_resource!('read', resource.folder)
    respond_with resource
  end

  def download_quicklink
    resource = find_resource_by_quicklink_hash!(params[:quicklink_hash])
    track_download(resource)
    resource.file_url
  end

  def gallery
    @gallery ||= account.galleries.find(params[:gallery_id]).tap do |resource|
      #authorization_service
      authorize_resource!(:read, resource)
    end
  end

  def folder
    if params[:query].present?
      nil
    else
      @folder ||= account.folders.find_by_id(params[:folder_id]).tap do |resource|
        authorize_resource!(:read, resource)
      end
    end
  end

  def download
    resource = resource_scope.where(downloadable: true).find(params[:id])
    track_download(resource)
    resource.file_url
  end

  private

    def account
      @account ||= @options[:account]
    end

    def readable_folder_ids
      @readable_folder_ids ||= begin
        if folder.present?
          [folder.id] # already authorized
        elsif params[:query].present?
          gallery.folders.select do |folder|
            authorize_resource!('read', folder) rescue false
          end.map(&:id)
        end
      end
    end

    # note: item should be available by hash regardless of permissions
    def find_resource_by_quicklink_hash!(quicklink_hash)
      resource = resource_class.where(quicklink_hash: quicklink_hash).first

      raise Errors::QuicklinkInvalid if resource.blank?
      if resource.quicklink_valid_to.present? && resource.quicklink_valid_to < DateTime.now
        raise Errors::QuicklinkExpired if resource.blank?
      end
      resource
    end

    def track_download(asset)
      download = asset.events.new name: 'download'
      download.target_owner = asset.account
      download.subject = @options[:user]
      download.save
    end

    # search by tag name too. based on
    # Asset.tagged_with(tags, :any => true) query
    def search_scope(base_scope, query)
      query.downcase!
      base_scope = base_scope.joins("LEFT OUTER JOIN taggings assets_taggings_7deb086 ON assets_taggings_7deb086.taggable_id = assets.id AND assets_taggings_7deb086.taggable_type = 'Asset' LEFT OUTER JOIN tags on assets_taggings_7deb086.tag_id = tags.id")
      base_scope = base_scope.where("lower(tags.name) like ? OR lower(title) LIKE ? OR lower(description) LIKE ?",
                       "%#{query}%", "%#{query}%", "%#{query}%")
      base_scope
    end

    # notes
    # account can be blocked only by password - we can easily use authenticate!(account)
    # blocked resource can be viewed by user with permissions ( or admin)
    # so we need custom methods for it 
    def authorize_resource!(action, resource)
      authenticate!(account)

      return true if action.to_sym == :read_all
      raise ActiveRecord::RecordNotFound if resource.blank? || resource.hidden?
      return true if resource.public?
      return true if resource.enable_password? && !!resource.authorized_keys.exists?(key: auth_hash)

      if !authorization_service.authorized?(action, resource)
        # if user haven't permissions, possible we can throw more detailed info
        authenticate!(resource)
        raise Errors::AuthorizationRequired.new('authorization required', resource: resource)
      end
      true
    end

    def authorization_service
      @authorization_service ||= Authorizers::Frontend.new(account: account, accessor: accessor)
    end
end
