class Invites::MyMemberResource < Cyrax::Resource
  resource :invite, class_name: 'GalleryMember'
  decorator Invites::BaseDecorator

  def resource_scope
    resource_class.where(gallery_id: my_gallery_ids).includes(:gallery, :user)
  end

  def build_resource(id, attributes = {})
    super(id, attributes)
  end

  def build
    assign_resource :galleries, account.galleries
    respond_with nil
  end

  def read_all
    assign_resource :admin_invitation_requests, InvitationRequest.admin.where(gallery_id: my_gallery_ids)
    assign_resource :viewer_invitation_requests, InvitationRequest.viewer.where(gallery_id: my_gallery_ids)
    read_all!
  end

  private

    def account
      @account ||= options[:account]
    end

    def my_gallery_ids
      @my_gallery_ids ||= account.galleries.pluck(:id)
    end
end
