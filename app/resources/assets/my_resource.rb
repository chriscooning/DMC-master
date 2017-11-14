class Assets::MyResource < Cyrax::Resource
  resource :asset
  accessible_attributes :title, :description, :folder_id, :downloadable, :tag_list,
                        :file_file_name, :file_file_size, :file_content_type, :position,
                        :custom_thumbnail, :quicklink_hash,
                        :quicklink_valid_to, :quicklink_downloadable
  decorator ::Assets::MyDecorator

  RESTRICTED_CHARS = /[&$+,\/:;=?@<>\[\]\{\}\|\\\^~%# ]/

  def read_all
    result = build_collection
    decorated_result = ::Assets::MyDecorator.decorate_collection(result)
    respond_with({ result: decorated_result, total_count: result.total_count })
  end

  def resource_scope
    raise Errors::AuthorizationRequired if accessor.blank?

    base_scope = account.assets
    unless accessor.account_owner?(account)
      base_scope = base_scope.where(folder_id: readable_folder_ids)
    end
    base_scope.order('position ASC')
  end

  def build_collection
    if params[:query].present?
      scope = gallery.assets
      unless accessor.account_owner?(account)
        scope = scope.where(folder_id: readable_folder_ids)
      end
      scope = search_scope(scope, params[:query])
    else
      scope = folder.assets
    end

    if params[:for_sorting].present?
      Kaminari::PaginatableArray.new scope.includes(:account), limit: 1000
    else
      scope.includes(:account).page(params[:page]).per(params[:per])
    end
  end

  def build_resource(id, attributes = {})
    super(id, attributes).tap do |asset|
      unless id.present?
        asset.secret ||= SecureRandom.hex(8)
        asset.processed = false unless asset.document?
        asset.file_file_name.gsub!(RESTRICTED_CHARS, '')
        if asset.title.blank?
          asset.title = FilenameParser.new(file_name: asset.file_file_name).title
        end
        asset.description = asset.title if asset.description.blank?
      end
    end
  end

  def create
    authorize_resource!('create_assets', folder)
    asset = create_without_validation
    {
      s3_credentials: {
        policy: s3_upload_policy_document(asset),
        signature: s3_upload_signature(asset),
        key: asset.s3_key
      },
      asset: {
        id: asset.id,
        title: asset.title,
        description: asset.description,
        file_file_name: asset.file_file_name,
        file_file_size: asset.file_file_size
      }
    }
  end

  def update
    authorize_resource!('update_assets', folder)
    asset = update_without_validation
    respond_with asset
  end

  def download
    resource = resource_scope.where(downloadable: true).find(params[:id])
    resource.file_url
  end

#  def update_multiple
#    create_folder('default') if folder.blank?
#
#    assets = resource_scope.where(id: params[:ids])
#    position = folder.assets.maximum(:position).to_i
#    result = assets.inject([]) do |array, asset|
#      asset.attributes = resource_attributes
#      asset.position = position += 1
#      asset.folder = folder
#      if save_resource(asset)
#        #TODO change this logic, maybe start video processing right after creating video asset ?
#        start_delayed_processing(asset) unless asset.document?
#        array << asset
#      else
#        add_errors_from(asset)
#      end
#      array
#    end
#    respond_with assets, present: :collection
#  end

  def update_multiple
    assets = []
    params[:assets].each do |index, asset_data|
      asset = resource_scope.where(id: asset_data[:id]).first
      asset.assign_attributes(asset_data.slice(*self.class.accessible_attributes))

      folder = find_folder(asset_data[:folder_id])
      if folder.blank?
        gallery = find_gallery(asset_data[:gallery_id])
        folder = gallery.folders.first || create_folder('default', gallery)
      end
      asset.folder = folder

      position = folder.assets.maximum(:position).to_i
      asset.position = position + 1

      if save_resource(asset)
        #TODO change this logic, maybe start video processing right after creating video asset ?
        start_delayed_processing(asset) unless asset.document?
        assets << asset
      else
        add_errors_from(asset)
      end
    end

    respond_with assets, present: :collection
  end

  def reorder
    attributes = params[:assets].values
    asset_ids = attributes.map{ |attrs| attrs[:id] }
    assets = resource_scope.where(id: asset_ids)

    # to be able sort assets, user should have ability to edit folders containing assets
    Folder.where(id: assets.map(&:folder_id).uniq).each do |folder|
      authorize_resource!('edit', folder)
    end

    # suppose, we have continuous set of positions
    positions_offset = assets.minimum(:position).to_i

    transaction do
      assets = assets.map do |asset|
        attrs = attributes.detect{|attrs| attrs[:id].eql?(asset.id.to_s) }

        asset.position = positions_offset + attrs[:position].to_i

        if asset.position_changed? && !save_resource(asset)
          add_errors_from(asset)
        end

        asset
      end

      folder.update_column :assets_sort_order, 'custom'
    end

    respond_with assets, present: :collection
  end

  # available orders
  def sort
    authorize_resource!('edit', folder)

    base_scope = Asset.where(folder_id: folder.id)
    sort_order = params[:sort_order]
    case params[:sort_order]
    when 'oldest_first'
      assets = base_scope.order('created_at asc')
    when 'by_title'
      assets = base_scope.order('title asc')
    when 'by_filename'
      assets = base_scope.order('file_file_name asc')
    else
      assets = base_scope.order('created_at desc')
      sort_order = 'newest_first'
    end

    transaction do
      assets.reverse.each_with_index do |asset, position|
        asset.update_column(:position, position) if asset.position != position
      end
      folder.update_column :assets_sort_order, sort_order
    end

    respond_with build_collection
  end

  def delete_resource(resource)
    resource.delete
  end

  def generate_quicklink
    resource = find_resource(params[:id])
    resource.update_column(:quicklink_url, quicklink_short_url)
    resource.update_column(:quicklink_valid_to, quicklink_expiration_date)
    quicklink_short_url
  end

  private

    def s3_upload_policy_document(asset)
      return @policy if @policy
      ret = {"expiration" => 15.minutes.from_now.utc.xmlschema,
        "conditions" =>  [
          {"bucket" =>  configatron.aws.bucket},
          ["starts-with", "$key", asset.s3_key],
          {"acl" => "public-read"},
          {"success_action_status" => "201"},
          ["content-length-range", 0, asset.file_file_size]
        ]
      }
      @policy = Base64.encode64(ret.to_json).gsub(/\n/,'')
    end

    def s3_upload_signature(asset)
      Base64.encode64(OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha1'), configatron.aws.secret_key, s3_upload_policy_document(asset)
      )).gsub("\n","")
    end

    def start_delayed_processing(asset)
      processor = case asset.asset_type
                  when :image then Workers::ImageProcessing
                  when :video then Workers::VideoProcessor
                  when :audio then Workers::AudioProcessor
                  end
      processor.enqueue(asset.id) if processor
    end

    def account
      @account ||= @options[:account]
    end

    def folder
      if params[:query].present?
        nil
      elsif params[:folder_id].present?
        @folder ||= find_folder(params[:folder_id])
      elsif params[:id].present?
        @folder ||= Asset.find(params[:id]).folder
      else
        nil
      end
    end

    def create_folder(name, folders_gallery = nil)
      folder_id = params[:folder_id]

      folders_gallery ||= gallery

      # user should be able to upload in newly created gallery [ he can forgot about creating folder first ]
      if (folder_id.blank? || folder_id == 'default') && folders_gallery.folders.blank? && authorization_service.authorized?('create_folders', folders_gallery)
        @folder = folders_gallery.folders.where(name: name).first_or_create
      else
        @folder = find_folder(folder_id)
      end
    end

    def find_folder(folder_id)
      account.folders.find_by_id(folder_id).tap do |resource|
        authorize_resource!(:read, resource)
      end
    end

    def gallery
      @gallery ||= find_gallery(params[:gallery_id])
    end

    def find_gallery(gallery_id)
      account.galleries.find(gallery_id).tap do |resource|
        authorize_resource!(:read, resource)
      end
    end

    def create_without_validation(custom_attributes=nil)
      resource = build_resource(nil, custom_attributes||resource_attributes)
      #resource.folder_id = nil # unless resource will be uploaded, not assign folders
      add_errors_from(resource) unless resource.save(validate: false)
      resource
    end

    def update_without_validation(custom_attributes=nil)
      prev_state = find_resource(resource_params_id)
      resource = build_resource(resource_params_id, custom_attributes||resource_attributes)
      if prev_state.folder_id != resource.folder_id
        folder = find_folder(resource.folder_id)
        position = folder.assets.maximum(:position).to_i
        resource.position = position + 1
      end
      add_errors_from(resource) unless resource.save(validate: false)
      resource
    end

    def authorization_service
      Authorizers::Backend.new(account: account, accessor: accessor)
    end

    def authorize_resource!(action, resource)
      authorization_service.authorize!(action, resource)
    end

    def readable_folder_ids
      if folder.present?
        folder.id
      else
        gallery.folders.map do |folder|
          authorization_service.authorized?('read', folder) ? folder.id : nil
        end.compact
      end
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

    def quicklink_short_url
      @quicklink_short_url ||= begin
        resource = find_resource(params[:id])
        asset_url = Rails.application.routes.url_helpers.quicklink_url(resource.quicklink_hash, host: resource.account.host)
        shortener = Googl.shorten(asset_url, accessor.current_sign_in_ip, configatron.google.shortener_key)
        shortener.short_url
      end
    end

    def quicklink_expiration_date
      return nil if params[:quicklink_valid_to].blank?
      date = Date.parse(params[:quicklink_valid_to])
      date <= Time.now.to_date ? nil : date
    rescue ArgumentError
      nil
    end
end
