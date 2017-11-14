class GalleryAuthenticator < BaseAuthenticator

  private

    def resource
      @resource ||= account.galleries.visible.find(params[:id])
    end
end
