class DMC.Views.Shared.Asset.List extends DMC.Views.Base
  itemClass: DMC.Views.Shared.Asset.Item
  noAssetsMessageTmpl: JST['templates/shared/no_items/assets']

  initialize: (options = {})->
    window.loading_page = false
    @pagination_containers = $(".pagination-container")
    @foldersCollection = options['foldersCollection']
    @urlRoot = options['urlRoot']
    @setElement $("#assets-list")
    @listenTo @collection, 'add', @addOne
    @listenTo @collection, 'reset', @addAll
    @listenTo @collection, 'reset', @appendInfiniteScroll
    @listenTo @collection, 'remove', @reRenderList
    @fetchCallback = options['fetchCallback']

    @reloadCollection()

#    @collection.fetch
#      reset: true
#      success: =>
#        @fetchCallback.trigger("fetch:end") if @fetchCallback?
#      error: (collection, xhr) =>
#        @fetchCallback.trigger("fetch:end") if @fetchCallback?
#        if xhr.responseJSON.code == 'password_required'
#          new DMC.Views.Frontend.FolderAuthorizationModal(collection: collection).render()
#        else
#          new DMC.Views.Frontend.MediaAuthorizationModal(folder_id: collection.folder_id).render()
    @

  reloadCollection: () =>
    @collection.fetch
      reset: true
      success: =>
        @fetchCallback.trigger("fetch:end") if @fetchCallback?
      error: (collection, xhr) =>
        @fetchCallback.trigger("fetch:end") if @fetchCallback?
        if xhr.responseJSON.code == 'password_required'
          new DMC.Views.Frontend.FolderAuthorizationModal(collection: collection).render()
        else
          new DMC.Views.Frontend.MediaAuthorizationModal(folder_id: collection.folder_id).render()

  windowScrolled: =>
    return false if @pending
    @pending = true
    scrollBeforePagination = $(document).height() - $(window).height() * 2
    if !window.loading_page && @collection.totalPages >= @collection.currentPage + 1 && $(window).scrollTop() > scrollBeforePagination
      window.loading_page = true
      @collection.requestNextPage
        update: true
        remove: false
        success: =>
          window.loading_page = false
          @pending = false
        error: =>
          @pending = false

  appendInfiniteScroll: =>
    debounced = $.debounce(@windowScrolled, 250, @)
    $(window).on 'scroll', => !@pending and debounced()

  render: ->
    @$el.empty()
    @

  addAll: ->
    @$el.empty()
    if @collection.length > 0
      @collection.each @addOne
    else
      @$el.append @noAssetsMessageTmpl()

  addOne: (model)=>
    folder = @foldersCollection.get(model.get('folder_id'))
    view = new @itemClass(model: model, folder: folder).render()
    @$el.append view.el


  reRenderList: ->
    @addAll()

  # this overrides some methods to
  # disable infinite scroll & add default paginations
  appendInfiniteScroll: ->
    true

  renderPagination: ->
    @pagination_containers.empty()
    pg = new DMC.Views.Shared.Pagination(collection: @collection, urlRoot: @urlRoot).render()
    @pagination_containers.append pg.el

  addAll: ->
    @$el.empty()
    @renderPagination()
    if @collection.length > 0
      @collection.each @addOne
    else
      @$el.append @noAssetsMessageTmpl()
