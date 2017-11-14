class Folders::MyDecorator < Cyrax::Decorator
  # cyrax decorator include active model serializers
  # You need to declare an attributes hash which contains the attributes you want to serialize.
  def attributes
    default_keys = %w{id name gallery_id position default_per_page}
    default_keys += %w{hide_folder hide_title hide_description enable_password}
    default_keys += %w{editable destroyable can_create_assets}
    # { id: nil, name: nil ... }
    Hash[*default_keys.map{|key| [key, nil]}.flatten]
  end

  def can_create_assets
    authorization_service.authorized?('create_assets', resource)
  end

  def editable
    authorization_service.authorized?('edit', resource)
  end

  def destroyable
    authorization_service.authorized?('destroy', resource)
  end

  def authorization_service
    options[:authorization_service] || Authorizers::Backend.new(account: resource.account, accessor: self.accessor)
  end
end
