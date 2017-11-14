class Roles::BaseResource < Cyrax::Resource
  decorator Roles::BaseDecorator

  resource :role, class_name: "Role"

  accessible_attributes :name, :description, permission_ids: []

  def resource_scope
    account.roles
  end

  def build_collection
    resource_scope.page(params[:page]).per(params[:per])
  end

  def edit
    edit! do |resource|
      authorize_resource!('read', resource)
    end
  end

  def create
    resource = build_resource(nil, resource_attributes)
    authorize_resource!(:create, resource)
    resource.save(validate: true)
    resource
  end

  def update(custom_attributes = nil, &block)
    resource = build_resource(resource_params_id, custom_attributes||resource_attributes)
    authorize_resource!(:update, resource)
    transaction do
      if save_resource(resource)
        set_message(:updated)
        block.call(resource) if block_given?
      end 
    end 
    respond_with(resource)
  end 

  private

    def account
      @account ||= options[:account]
    end

    def build_resource(id, attributes = {})
      super(id, attributes).tap do |resource|
        resource.account_id = account.id
        resource.attributes = attributes
      end
    end

    def authorize_resource!(action, resource)
      if action.to_s == 'read' || action.to_s == 'read_all'
        authorization_service.authorize!(:view_subaccounts, account)
      else
        authorization_service.authorize!(:edit_subaccounts, account)
      end
    end

    def authorization_service
      Authorizers::Backend.new(account: account, accessor: accessor)
    end
end
