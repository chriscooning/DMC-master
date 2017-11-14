class DMC.Views.Backend.Modals.AssetUploader extends DMC.Views.Backend.Folder.Uploader
  className: 'modal fade'
  template: JST['templates/backend/modals/asset_uploader']

  events: _.extend({
    'change #galleries' : 'gallerySelectedHandler'
    'change #folders'   : 'folderSelectedHandler'
  }, DMC.Views.Backend.Folder.Uploader::events)

  initialize: (options = {})->
    @options = options

    # init
    @galleries = options['galleries'] || new DMC.Collections.Galleries()
    @folders   = options['folders']  || new DMC.Collections.Folders([], {})
    # override url to fetch all folders, not only for specific gallery
    @folders.url = () -> window.subdomainUrl("/folders")
    # collection to store created assets
    @assets = new DMC.Collections.Assets()

    # listeners
    _.bindAll(@, 'renderCategories', 'renderGalleriesOptions', 'renderFoldersOptions')
    @listenTo @galleries, 'reset', @renderGalleriesOptions
    @listenTo @folders,   'reset', @renderFoldersOptions
    @
    
  render: ->
    @$el.html(@template())
    $.when( (=>
      if (@galleries.length == 0) then @galleries.fetch()
    )(), (=>
      if (@folders.length == 0) then @folders.fetch()
    )()).then(@renderCategories)
    @createButton = @$(".save-files")
    @

  show: ->
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

  # override parent methods
  afterClose: ->
    @trigger('destroyed')
