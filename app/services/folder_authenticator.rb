class FolderAuthenticator < BaseAuthenticator

  private

    def resource
      @resource ||= gallery.folders.visible.find(params[:id])
    end

    def gallery
      @gallery ||= account.galleries.visible.find(params[:gallery_id])
    end
end
