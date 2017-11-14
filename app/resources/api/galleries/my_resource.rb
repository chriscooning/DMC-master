class Api::Galleries::MyResource < Cyrax::Resource
  resource :gallery
  serializer MySerializer

  def resource_scope
    account.try(:galleries)
  end

  def account
    accessor.primary_account
  end
end
