class BlogPostsController < ApplicationController
  respond_to :html

  def index
    respond_with resource.read_all
  end

  def show
    respond_with resource.read
  end

  private

    def resource
      @resource ||= BlogPosts::BaseResource.new(params: params)
    end
end