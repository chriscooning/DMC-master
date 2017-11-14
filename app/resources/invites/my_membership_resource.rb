class Invites::MyMembershipResource < Cyrax::Resource
  resource :invite, class_name: 'GalleryMember'
  decorator Invites::BaseDecorator

  def resource_scope
    accessor.gallery_membership.includes(gallery: :user)
  end
end