class DMC.Views.Backend.Asset.Form extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/assets/form']
  modelFormSelector: '.asset-attributes'

  events:
    'shown.bs.modal'    : 'afterOpening'
    'hidden.bs.modal'   : 'afterClose'
    'click .update'     : 'save'
    'change #galleries' : 'gallerySelectedHandler'
    'change #folders'   : 'folderSelectedHandler'


  initialize: (options)->
    super
    @options = options
    @galleries = options['galleries'] || new DMC.Collections.Galleries()
    @folders   = options['folders']   || new DMC.Collections.Folders([], {})
    
    @folders.url = () -> window.subdomainUrl("/folders")

    _.bindAll(@, 'renderCategories', 'renderGalleriesOptions', 'renderFoldersOptions')
    @listenTo @galleries, 'reset', @renderGalleriesOptions
    @listenTo @folders,   'reset', @renderFoldersOptions
    @

  render: ->
    @$el.html @template(@model.asJSON())
    $.when( (=>
      if (@galleries.length == 0) then @galleries.fetch()
    )(), (=>
      if (@folders.length == 0) then @folders.fetch()
    )()).then(@renderCategories)
    @$el.modal()
    @

  renderCategories: () ->
    if @options.gallery_id
      @options.gallery_id = parseInt(@options.gallery_id)
    else
      if @galleries.length > 0
        @options.gallery_id = @galleries.first().id
    @renderGalleriesOptions()
    @renderFoldersOptions()
    return true

  renderGalleriesOptions: () ->
    options = { selected: @options.gallery_id, show_default: false }
    @renderSelectorOptions(@$el.find('#galleries'), @galleries.models, options)
    return true

  renderFoldersOptions: () ->
    options = { selected: @options.folder_id, show_default: true }
    if @options.gallery_id
      options.scope = { gallery_id: @options.gallery_id }
    @renderSelectorOptions(@$el.find('#folders'), @folders.models, options)
    return true

  renderSelectorOptions: (selector, models, options = {}) ->
    $select = (selector)
    $select.empty()

    if !_.isEmpty(options.scope)
      is_visible = _.matches(options.scope)
      visible_models = _.filter(models, (model) -> is_visible(model.attributes))
    else
      visible_models = models

    _.each(visible_models, (model) ->
      $select.append $('<option />', value: model.get('id'), text: model.get('name'))
    )

    if options.show_default && models.length == 0
      $select.append $('<option />', text: 'default', id: '0')

    if options.selected
      $select.val(options.selected)

  gallerySelectedHandler: (e) ->
    gallery_id = @$el.find('#galleries').val()
    if gallery_id
      @options.gallery_id = parseInt(gallery_id)
      @options.folder_id  = null
    else
      @options.gallery_id = null
    @renderFoldersOptions()

  folderSelectedHandler: (e) ->
    folder_id = @$el.find('#folders').val()
    folder = @folders.get(@options.folder_id)
    if folder
      @options.folder_id = parseInt(folder_id)
      @options.gallery_id = folder.get('gallery_id')
    else
      @options.folder_id = null
    @renderGalleriesOptions()

  save: ->
    super

    attributes = @$(@modelFormSelector).serializeObject()
    @folder_id = @model.collection.folder_id

    if @folder_id != attributes.folder_id
      @assetCollection = new DMC.Collections.Assets([],
        gallery_id: @folders.gallery_id,
        folder_id: @folder_id,
        folder: @model.collection.folder
      )

      @assetsView = new DMC.Views.Backend.Asset.List(
        collection: @assetCollection,
        foldersCollection: @folders,
        urlRoot: "#!folders/#{@folder_id}",
        fetchCallback: @fetchCallback
      ).render()


  afterOpening: ->
    @$("#tags-input").tagsInput
      height: 'auto'
      width: '100%'
    @$("#description").redactor
      minHeight: 200
      buttons: ['html', '|', 'formatting', '|', 'bold', 'italic', 'deleted', '|',
                'unorderedlist', 'orderedlist', 'outdent', 'indent', '|',
                'link', '|', 'alignment', '|', 'horizontalrule']

    @$("#alter-thumb").fileupload
      url: @model.url()
      dataType: 'json'
      type: 'PATCH'
      autoUpload: true
      previewMaxWidth: 300
      previewMaxHeight: 300
      progressall: (e, data)=>
        progress = parseInt(data.loaded / data.total * 100, 10)
        @$('#progress .bar').css 'width', progress + '%'

      done: (e, data)=>
        that = @$("#alter-thumb").data('blueimp-fileupload') ||
          @$("#alter-thumb").data('fileupload')
        data.context = @$("#video-preview")
        @$("#video-preview .preview").empty()
        that._renderPreviews(data)
        @model.fetch()

    @$("#alter-thumb").on 'fileuploadadd', =>
      @$("#progress").fadeIn()

    @$("#alter-thumb").on 'fileuploaddone', =>
      @$("#progress").fadeOut()
