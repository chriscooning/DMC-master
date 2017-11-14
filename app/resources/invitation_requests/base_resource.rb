class InvitationRequests::BaseResource < Cyrax::Resource
  resource :invite, class_name: 'InvitationRequest'
  accessible_attributes :email

  private

  def gallery
    @gallery ||= account.galleries.find(params[:gallery_id])
  end

  def account
    @account ||= options[:account]
  end

  def resource_scope
    if accessor.present?
      gallery.invites.where(user_id: accessor.id)
    else
      gallery.invites
    end
  end

  def build_resource(resource_id, attributes = {})
    if (email = attributes[:email]).present?
      resource_scope.where(email: email).first_or_initialize
    else
      resource_scope.new(email: attributes[:email])
    end
  end
end
