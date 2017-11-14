class DMC.Views.Backend.Folder.Uploader extends DMC.Views.Shared.Form.Base
  className: 'modal fade'
  template: JST['templates/backend/folder/uploader']

  events:
    'shown.bs.modal': 'afterOpening'
    'hidden.bs.modal': 'afterClose'
    'click .save-files': 'handleFileSaving'
    'click .add-files': 'validateGalleryPresence'

  initialize: (options)->
    super
    @folders = options['folders']
    @folder_id = options['folder_id'] || null
    @assets = new DMC.Collections.Assets()
    @folder_to_show = null
    @

  render: ->
    $template = $ @template()
    @$el.html $template
    @renderCategories()
    @createButton = @$(".save-files")
    @$el.modal()
    @

  renderCategories: ->
    $select = @$('#folders')
    @folders.each (model)->
      $option = $('<option />',
        value: model.get('id'),
        text: model.get('name')
      )
      $select.append $option
    $select.val @folder_id
    if @folders.length == 0
      $select.append $('<option />', text: 'default', id: '0')

  handleFileSaving: ->
    formData = @$('.file-attributes').serializeObject()
    if @assets.length > 0
      asset = @assets.last()
      _.each(formData, (value, key) ->
        asset.set(key, value) if !_.isEmpty(value)
      )
      asset.set(stored: _.isEmpty(asset.changed))

    assets = @assets.filter((asset) -> asset.get('uploaded'))
    closeCallback = _.bind(() ->
      @close(silently: true)
    , @)

    if _.isEmpty(assets)
      @showEmptyError()
      @hideCreateButton()
    else
      @disableCreateButton()
      @storeAssetsOnServer(assets).success(closeCallback)

  validateGalleryPresence: ->
    if @$el.find('#galleries').length > 0 and !@$el.find('#galleries').val()
      @clearErrors()
      $error = $('<span/>',
        class: 'error help-block'
        text: 'You must first chose a gallery'
      )
      $(".fileupload-buttonbar .btn-group").append $error
      false

  # post "/update_multiple" assigns asset to specific folder - makes asset visible
  storeAssetsOnServer: (assets) ->
    assets = @assets.filter((asset) ->
      asset.get('uploaded') && !asset.get('stored')
    )
    return true if assets.length == 0

    create_new_folder = true if @folders.length == 0

    assets_attributes = _.map(assets, (asset) ->
      _.extend({}, asset.attributes)
    )

    collection = @assets
    $.ajax
      url: window.subdomainUrl("/assets/update_multiple")
      type: 'POST'
      dataType: 'json'
      data: { assets: assets_attributes }
      success: (data) =>
        if window.DMC.collection.constructor == DMC.Collections.Folders
          folder_id = data[0].folder_id
          if create_new_folder
            folder = new DMC.Models.Folder(name: 'default', id: folder_id, can_create_assets: true)
            window.DMC.collection.add(folder)
          @folder_to_show = folder_id

        data
      error: (xhr) =>
        console.log('error')
        @enableCreateButton()
        @handleErrors(xhr)
      failure: (xhr)=>
        @enableCreateButton()

  disableCreateButton: =>
    @$('.save-files').addClass('unavailable')

  enableCreateButton: =>
    $('.save-files').removeClass('unavailable')

  showEmptyError: ->
    @clearErrors()
    $error = $('<span/>',
      class: 'error help-block'
      text: 'Upload something!'
    )
    $(".fileupload-buttonbar .btn-group").append $error

  afterOpening: ->
    @$("#tags-input").tagsInput
      height: 'auto'
      width: '100%'
    @$("#description").redactor
      minHeight: 200
      buttons: ['html', '|', 'formatting', '|', 'bold', 'italic', 'deleted', '|',
                'unorderedlist', 'orderedlist', 'outdent', 'indent', '|',
                'link', '|', 'alignment', '|', 'horizontalrule']
    @$("#file-uploader").fileupload
      autoUpload: true
      singleFileUploads: true
      limitMultiFileUploads: 1
      maxFileSize: 500,
      url: "//#{window.awsBucket}.s3.amazonaws.com"
      type: 'POST'
      dataType: 'xml'
      filesContainer: $("#files tbody")
      downloadTemplateId: 'templates/backend/assets/uploaded'
      uploadTemplateId: 'templates/backend/assets/upload'
      getFilesFromResponse: (data)->
        [data.asset_data]

      destroy: (e, data)->
        that = $(this).data('blueimp-fileupload') || $(this).data('fileupload')
        if (data.url)
          data.dataType = 'json'
          $.ajax(data)
        that._transition(data.context).done ->
          $(this).remove()
          that._trigger('destroyed', e, data)

      # note: we overrided add function for plugin, some functionality may be not available
      add: (e, data)=>
        # process processActions
        try
          @hideCreateButton()
          @doAdd(e, data)
        finally
          @refreshCreateButtonVisibility()

    @$("#file-uploader").on 'fileuploadcompleted', _.bind((e, data) ->
      if data.asset_data.id and @assets.get(data.asset_data.id)
        asset = @assets.get(data.asset_data.id)
        asset.set(uploaded: true)
        @markRowAsStoredToServer(asset)
        @storeAssetsOnServer([asset]).success( () ->
          asset.set(stored: true)
        )
    , @)

    @$("#file-uploader").on 'fileuploadstopped', =>
      @refreshCreateButtonVisibility()

    @$("#file-uploader").on 'fileuploadfail', (e, data) =>
      data.context.replaceWith( JST['templates/backend/assets/uploaded_failed'](asset: data.asset_data))
      @refreshCreateButtonVisibility(onFail: true)

    @$("#file-uploader").on 'fileuploaddestroyed', =>
      @refreshCreateButtonVisibility()

  doAdd: (e, data)=>
    @clearErrors()
    $this = @$("#file-uploader")
    that = $this.data('blueimp-fileupload') || $this.data('fileupload')
    files = data.files
    options = that.options

    $form = $('.modal-dialog .file-attributes')
    addAssetToCollection = _.bind(@addAssetToCollection, @)

    data.process().always ->
      data.context = that._renderUpload(files).data('data', data)
      that._renderPreviews(data)
      options.filesContainer[if options.prependFiles then 'prepend' else 'append'](data.context)
      that._forceReflow(data.context)
      that._transition(data.context)
    .done ->
      file = data.files[0]
      $.ajax
        async: true
        url: window.subdomainUrl("/assets")
        type: 'POST'
        data:
          asset: _.extend({}, $form.serializeObject(), {
            file_file_name: file.name
            file_file_size: file.size
            file_content_type: file.type
          })
        success: (result) ->
          # submit form to s3
          asset_data = result.asset
          s3_credentials = result.s3_credentials
          $("#file-uploader input[name=key]").val s3_credentials.key
          $("#file-uploader input[name=policy]").val s3_credentials.policy
          $("#file-uploader input[name=signature]").val s3_credentials.signature
          data.asset_data = asset_data
          data.submit()

          addAssetToCollection(asset_data)

  addAssetToCollection:(asset_data) ->
    $form = @$el.find('.modal-dialog .file-attributes')
    folder = @folders.get($form.find('#folders').val())
    if folder
      asset_data.folder_id  = folder.get('id')
      asset_data.gallery_id = folder.get('gallery_id')
    else
      gallery = @galleries.get($form.find('#galleries').val())
      if gallery
        asset_data.gallery_id = gallery.get('id')
      else
        asset_data.gallery_id = @folders.gallery_id

    @assets.add(new DMC.Models.Asset(asset_data))
    @assets

  refreshCreateButtonVisibility:(opts = {}) ->
    if @assets.filter((asset) -> asset.get('uploaded')).length > 0
      @showCreateButton()
      @enableCreateButton()
    else
      @hideCreateButton()

  showCreateButton: ->
    @createButton.removeClass('hide')

  hideCreateButton: ->
    @createButton.addClass('hide')

  markRowAsStoredToServer:(asset) ->
    $tr = $(".modal-dialog tr.fade.template-download[data-id=#{ asset.id}]")
    $tr.find('td:first').append('<span class="glyphicon glyphicon-ok"></span>')
    $tr.find('td:nth-child(2)').append('<br/><span class="label label-info">Processing</span>')

  afterClose: ->
    super
    if @silently
      if @folder_to_show
        Backbone.history.navigate("!folders/#{@folder_to_show}", trigger: true)
      else
        Backbone.history.navigate("!")
