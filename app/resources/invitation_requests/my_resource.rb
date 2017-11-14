class InvitationRequests::MyResource < Cyrax::Resource
  resource :invite, class_name: 'InvitationRequest'

  def resource_scope
    resource_class.includes(:gallery).where('galleries.account_id = ?', account.id)
  end

  def read_all!
    assign_resource :admin_invitation_requests, InvitationRequest.admin.where(gallery_id: my_gallery_ids)
  end

  def account
    @account ||= options[:account]
  end
end
