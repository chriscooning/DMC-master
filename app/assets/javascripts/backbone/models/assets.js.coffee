class DMC.Models.Asset extends DMC.Libs.BaseModel
  modelAttributes: [
    'id', 'title', 'description', 'downloadable', 'folder_id', 'is_image', 'is_video',
    'thumb_url', 'file_url', 'video_urls', 'processed', 'pdf_preview_url'
  ]
  accessibleAttributes: [
    'title', 'description', 'downloadable', 'folder_id', 'tag_list', 'position',
    'thumb_url', 'is_video', 'custom_thumbnail', 'quicklink_downloadable', 'quicklink_valid_to'
  ]
  methodAttributes: ['tags', 'download', 'show_title', 'has_preview']
  paramRoot: 'asset'

  defaults:
    downloadable: true
    processed: true
    thumb_url: null

  initialize: (attributes, options = {})->
    super
    @gallery_id = options['gallery_id']
    @

  tags: ->
    @get('tag_list') || @get('cached_tag_list')

  # removed as title is generated on server from file name if not supplied
  # validate: (attrs, options)->
  #   { title: ["Please enter title"] } unless attrs.title

  has_preview: ->
    ! /\.(docx?|pptx?|ai|eps|txt|zip|xlsx?)$/i.test(@get('file_file_name'))

  fetch_video: ->
    return unless @get('is_video') && !@get('processed')
    @timer = setInterval =>
      if @get('processed')
        @trigger('change')
        clearInterval(@timer)
      else
        @fetch(silent: false)
    , 10000

  destroy: (options)->
    clearInterval(@timer) if @timer
    super

  smil_manifest: ->
    gallery_id = @gallery_id || @collection.gallery_id
    "/galleries/#{gallery_id}/folders/#{@get('folder_id')}/assets/#{@get('id')}/manifest.smil"

  download: ->
    gallery_id = @gallery_id || @collection.gallery_id
    "/galleries/#{gallery_id}/folders/#{@get('folder_id')}/assets/#{@get('id')}/download"

  show_title: ->
    return true unless @collection && @collection.folder
    @collection.folder.get('show_title')


class DMC.Collections.Assets extends Backbone.Paginator.requestPager
  model: DMC.Models.Asset

  initialize: (models, options = {})->
    super
    @query = options['query'] || ''
    @gallery_id = options['gallery_id']
    @folder_id = options['folder_id']
    @folder = options['folder']
    @forSorting = options['forSorting']
    @updatePerPage()
    @

  url: -> window.subdomainUrl("/galleries/#{@gallery_id}/folders/#{@folder_id}/assets")


  paginator_core:
    type: 'GET'
    dataType: 'json'
    url: -> @url()

  paginator_ui:
    firstPage: 1
    currentPage: 1
    perPage: 16
    totalPages: 0

  server_api:
    per: -> @perPage
    page: -> @currentPage
    for_sorting: -> @forSorting
    query: -> @query
    format: 'json'

  updatePerPage: ->
    @perPage = parseInt(@folder.get('default_per_page')) if @folder

  parse: (response) ->
    @totalPages = Math.ceil(response.total_count / @perPage)
    @totalRecords = response.total_count
    response.result

  sort: (sort_order) ->
    sort_order or= 'newest_first'
    folder = @folder
    $.ajax
      url: @url() + '/sort'
      data:
        sort_order: sort_order
        _method: 'put'
      dataType: 'JSON'
      type: 'POST'
    .complete( (assets) =>
      folder.set('assets_sort_order', sort_order)
      @trigger('reorder')
    )

  reorder: (data) ->
    $.ajax
      url: @url() + '/reorder'
      data:
        assets: data
        _method: 'put'
      dataType: 'JSON'
      type: 'POST'
