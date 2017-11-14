class BlogPosts::BaseResource < Cyrax::Resource
  resource :blog_post
  decorator BlogPosts::BaseDecorator

  def resource_scope
    resource_class.published
  end

  def build_collection
    resource_scope.page(params[:page])
  end
end