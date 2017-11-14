class DMC.Views.Backend.Asset.List extends DMC.Views.Shared.Asset.List
  itemClass: DMC.Views.Backend.Asset.Item

  appendInfiniteScroll: -> true

  initialize: (options = {})->
    super
    @listenTo @collection, 'reorder', @reloadCollection

  cleanup: () ->
    @sort_selector && @sort_selector.cleanup()
    super

  addAll: ->
    @$el.empty()
    @renderPagination()
    @renderSortContainer()
    if @collection.length > 0
      @collection.each (item) => @addOne(item)
    else
      @$el.append @noAssetsMessageTmpl()

  renderPagination: ->
    @pagination_containers.empty()
    pg = new DMC.Views.Shared.Pagination(collection: @collection, urlRoot: @urlRoot).render()
    @pagination_containers.append pg.el

  renderSortContainer: ->
    @sort_selector ||= new DMC.Views.Shared.SortSelector(
      el: $('#search-container .sort-selector'),
      collection: @collection,
    )
    @sort_selector.render()
