class Galleries::MyDecorator < Cyrax::Decorator
  # cyrax decorator include active model serializers
  # You need to declare an attributes hash which contains the attributes you want to serialize.
  def attributes
    default_keys = %w{id name visible show_first position editable destroyable}
    default_keys += %w{enable_password enable_invitation_credentials folders_can_be_managed folders_can_be_created}
    # { id: nil, name: nil ... }
    Hash[*default_keys.map{|key| [key, nil]}.flatten]
  end

  def editable
    authorization_service.authorized?('edit', resource)
  end

  def destroyable
    authorization_service.authorized?('destroy', resource)
  end

  def folders_can_be_created
    authorization_service.authorized?('create_folders', resource)
  end

  def folders_can_be_managed
    authorization_service.authorized?('create_folders', resource) && authorization_service.authorized?('sort_folders', resource)
  end

  def authorization_service
    #Authorizers::Backend.new(account: resource.account, accessor: self.accessor)
    options[:authorization_service] || Authorizers::Backend.new(account: resource.account, accessor: self.accessor)
  end
end
