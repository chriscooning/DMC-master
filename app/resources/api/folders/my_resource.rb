class Api::Folders::MyResource < Cyrax::Resource
  resource :folder
  serializer MySerializer

  def resource_scope
    gallery.folders
  end

  private

    def gallery
      @gallery ||= account.galleries.find(params[:gallery_id])
    end

    def account
      accessor.primary_account
    end
end
