class Invites::MyRequestResource < Cyrax::Resource
  resource :invite, class_name: 'InvitationRequest'

  def resource_scope
    resource_class.where(gallery_id: my_gallery_ids)
  end

  private

    def my_gallery_ids
      @my_gallery_ids ||= accessor.galleries.pluck(:id)
    end
end