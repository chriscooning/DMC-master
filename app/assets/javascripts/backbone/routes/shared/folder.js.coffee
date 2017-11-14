class DMC.Routers.Shared.Folder extends Backbone.Router
  assetsListClass: DMC.Views.Shared.Asset.List
  assetShowClass: DMC.Views.Shared.Asset.Show

  routes:
    '!': 'index'
    '!folders/:id': 'showFolder'
    '!folders/:id/page/:page': 'showFolder'
    '!assets/:id': 'showAsset'
    '!search/(:query)': 'searchAssets'
    '!search/(:query/)page/:page': 'searchAssets'

  initialize: (options)->
    super
    @collection = options['collection']
    @gallery    = options['gallery']
    @first_time = true
    @pending    = false
    @fetchCallback = _.extend({}, Backbone.Events) # event mediator
    @fetchCallback.bind("fetch:end", @onFetchFinish, @)

  showFirstFolder: ->
    if @collection.length && !@folder_id
      @navigate("!folders/#{@collection.first().id}", trigger: true)
    else
      @showFoldersIsEmpty()

  index: ->
    @modal.close() if @modal

  navigateToActiveFolder: (opts = {}) ->
    if @folder_id
      @navigate("!folders/#{@folder_id}", opts)
    else
      @navigate("!")

  showFoldersIsEmpty: () ->
    # we should show 'no-folders' view and replace given html
    $('#assets-list.row .col-md-12').hide()

  showFolder: (id, page = 1)->
    @assetCollection.query = '' if @assetCollection
    $('#search').val('')
    return if @pending
    @onFetchStart()
    folder = @collection.get(id)
    return false unless folder
    @folder_id = id
    @makeFolderActive(id)

    if @assetCollection is undefined
      @assetCollection = new DMC.Collections.Assets([], gallery_id: @collection.gallery_id, folder_id: id, folder: folder)

    if @assetCollection.folder_id != @folder_id
      @assetCollection.reset()
      @assetCollection.folder_id = @folder_id
      @assetCollection.folder = folder

    @assetCollection.currentPage = parseInt(page)
    @assetsView && @assetsView.cleanup()
    @assetsView = new @assetsListClass(
      collection: @assetCollection,
      foldersCollection: @collection,
      urlRoot: "#!folders/#{@folder_id}",
      fetchCallback: @fetchCallback
    )
    # commented out - avoid empty assets list while collection fetching
    #@assetsView.render()

  onFetchStart: () ->
    @pending = true
    $('.nav-pills').addClass('disabled')

  onFetchFinish: () ->
    @pending = false
    $('.nav-pills').removeClass('disabled')

  searchAssets: (query, page = 1)->
    $("#search").val(query)
    @assetCollection = new DMC.Collections.Assets([], gallery_id: @collection.gallery_id, folder_id: 0, query: query)
    @assetCollection.currentPage = parseInt(page)
    @assetCollection.query = query
    @assetsView && @assetsView.cleanup()

    query = query && query.replace /^\s+|\s+$/g, ""
    if query && query.length > 0
      @assetsView = new @assetsListClass(
        collection: @assetCollection,
        foldersCollection: @collection,
        urlRoot: "#!search/#{query}",
        fetchCallback: @fetchCallback
      ).render()
    else
      @navigateToActiveFolder(trigger: true)

  makeFolderActive: (id)->
    $('#folders-list li.active').removeClass('active')
    $("#folders-list a[data-id='#{id}']").parent().addClass('active')

  showAsset: (id)->
    return unless @assetCollection
    if asset = @assetCollection.get(id)
      @modal && @modal.cleanup() && @modal.close()
      @modal = new @assetShowClass(model: asset).render()
      @listenToOnce @modal, 'destroyed', => @navigate("!folders/#{@folder_id}")
