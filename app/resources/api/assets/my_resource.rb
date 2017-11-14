class Api::Assets::MyResource < ::Api::BaseResource
  DEFAULT_PAGE = 1
  DEFAULT_PER  = 16

  resource :asset
  serializer MySerializer
  decorator Api::Assets::MyDecorator

  def resource_scope
    page = params[:page].present? ? params[:page] : DEFAULT_PAGE
    per  = params[:per].present?  ? params[:per]  : DEFAULT_PER
    folder.assets.page(page).per(per)
  end

  private

    def folder
      return @_folder if @_folder.present?
      gallery   = require_record('Gallery') { gallery = account.galleries.find(params[:gallery_id]) }
      @_folder  = require_record('Folder') { gallery.folders.find(params[:folder_id]) }
    end

    def account
      accessor.primary_account
    end
end
