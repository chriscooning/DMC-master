class Galleries::MyResource < Cyrax::Resource
  include Authentication::ResourceHelper
  DEFAULT_PER = 10

  decorator ::Galleries::MyDecorator

  resource :gallery
  accessible_attributes :name, :logo, :gallery_message, :restrictions_message,
                        :help_message, :visible, :logo_url, :logo_text, :enable_password, :password,
                        :enable_invitation_credentials, :featured, :featured_image,
                        menu_links_attributes: [:link, :content, :_destroy, :id, :position]

  def resource_scope
    raise Errors::AuthorizationRequired if accessor.blank?

    base_scope = account.galleries
    unless accessor.account_owner?(account)
      base_scope = base_scope.where(id: readable_resource_ids)
    end
    base_scope.order('position ASC')
  end

  def read
    resource = resource_class.includes(:menu_links).find(params[:id])
    authorize_resource!(:read, resource)
    # TODO: load with resource
    assign_resource :folders, available_folders(resource), as: accessor, decorator: Folders::MyDecorator, present: :collection, authorization_service: authorization_service
    assign_resource :my_galleries, resource_scope.map { |g| [g.id, g.name] }
    respond_with resource, authorization_service: authorization_service
  end

  def edit
    resource = resource_class.includes(:menu_links).find(params[:id])
    authorize_resource!(:read, resource)
    respond_with resource
  end

  def build_resource(id, attributes = {})
    super(id, attributes).tap do |gallery|
      if gallery.password.present?
        gallery.encrypted_password = ::BCrypt::Password.create("#{gallery.password}#{Gallery.pepper}", cost: 1)
      end
      if gallery.position == 0
        gallery.position = resource_scope.maximum(:position).to_i + 1
      end
      gallery.show_first = false if gallery.protected?
      if gallery.featured?
        resource_scope.where('id != ?', id).update_all(featured: false)
      end
    end
  end

  def create
    create! do |gallery|
      # NOTE: heavy permissions management
      gallery.create_permissions
      accessor.permissions << gallery.permissions
      # assign read permissions on this element to all primary
      gallery.account.primary_users.each do |primary_user|
        primary_user.permissions << gallery.permissions.where(action: 'read')
      end
    end
  end

  def update
    update! do |gallery|
      clean_up_passwords(gallery)
    end
  end

  def toggle_first
    resource = find_resource(params[:id])
    authorize_resource!(:update, resource)

    if resource.show_first?
      resource.update_column(:show_first, false)
    else
      if resource.protected?
        add_error(:base, "You can't make password protected/media credential gallery first!")
      else
        resource_scope.update_all(show_first: false)
        resource.update_column(:show_first, true)
      end
    end

    respond_with(resource)
  end

  def reorder
    params[:order] ||= {}
    galleries = resource_scope.where(id: params[:order].keys)
    authorize_resource!(:sort_galleries, account)
    ActiveRecord::Base.transaction do
      galleries.each { |gallery| gallery.update_column(:position, params[:order][gallery.id.to_s]) }
    end
  end

  def delete_resource(resource)
    resource.destroy
  end

  def read_portal
    announcements = account.announcements.page(1).per(configatron.pagination.announcements.per)
    assign_resource :announcements, announcements
    galleries = resource_scope.order('featured DESC')
    respond_with galleries, 
      name: collection_name,
      present: :collection,
      authorization_service: authorization_service
  end

  private

    def clean_up_passwords(resource)
      resource.password = nil
    end

    def account
      @account ||= ( @options[:account] || accessor.primary_account )
    end

    def authorize_resource!(action, resource)
      authorization_service.authorize!(action, resource)
    end

    def authorization_service
      @authorization_service ||= Authorizers::Backend.new(account: account, accessor: accessor)
    end

    def readable_resource_ids
      account.galleries.collect do |gallery|
        authorization_service.authorized?('read', gallery) ? gallery.id : nil
      end.compact
    end

    def available_folders(resource)
      if accessor.account_owner?(account)
        resource.folders
      else
        resource.folders.select do |folder|
          authorization_service.authorized?('read', folder)
        end
      end
    end
end
