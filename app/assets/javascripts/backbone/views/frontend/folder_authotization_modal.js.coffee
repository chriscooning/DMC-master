class DMC.Views.Frontend.FolderAuthorizationModal extends DMC.Views.Frontend.PasswordAuthorizationModal
  
  url: ->
    "/galleries/#{@gallery_id}/folders/#{@folder_id}/authenticate"

  initialize: (options)->
    super
    @collection = options['collection']
    @gallery_id = @collection.gallery_id
    @folder_id = @collection.folder_id
    @

  processResponce: (data)=>
    if data.errors
      _.each(data.errors, @renderErrors)
    else
      @close(silently: true)
      @collection.fetch(reset: true)
      false