class Api::UserTokens::BaseSerializer < Cyrax::Serializer
  attributes :token, :expire_at
end
