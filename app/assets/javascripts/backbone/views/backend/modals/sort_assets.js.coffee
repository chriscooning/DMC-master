class DMC.Views.Backend.Modals.SortAssets extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/modals/sort_assets']
  itemTemplate: JST['templates/backend/modals/sort_assets_item']

  events:
    'hide.bs.modal': 'beforeClose'
    'hidden.bs.modal': 'afterClose'
    'click .make-first': 'makeAssetFirst'
    'click .make-last': 'makeAssetLast'

  initialize: (options) ->
    super
    @queues =
      sorting:
        next: null
        busy: false
        pending: false
    @folder = options['folder']
    @collection = new DMC.Collections.Assets [],
      folder_id: @folder.get('id'),
      gallery_id: @folder.get('gallery_id'),
      forSorting: true
    @listenTo @collection, 'reset', @addAll

    @collection.fetch({reset: true})
    @

  render: ->
    @$el.html @template()
    @$list = @$('.assets-sort-list')
    @$list.sortable
      handle: '.glyphicon-resize-vertical'
      items: '> .row'
      update: (e, ui)=>
        @renderPageDelimeter()
        @handleSorting()
        true

    @$el.modal()
    @

  renderPageDelimeter: ->
    @$list.find('hr').remove()
    @$list.find('.row').each (i, el)=>
      $(el).after $('<hr/>') if (i+1) % @folder.get('default_per_page') == 0
        

  addAll: ->
    @collection.each (el)=>
      @$list.append @itemTemplate(el.attributes)
    @renderPageDelimeter()

  makeAssetFirst: (e)->
    $this = $(e.target).parents('.row')
    new_index = 0
    old_index = $this.index()
    return unless new_index != old_index
    $this.insertBefore(@$list.find('.row:first'))
    @handleSorting()

  makeAssetLast: (e)->
    $this = $(e.target).parents('.row')
    new_index = @$list.find('.row').length - 1
    old_index = $this.index()
    return unless new_index != old_index
    $this.insertAfter(@$list.find('.row:last'))
    @handleSorting()

  processSorting: (recall = false) ->
    if @queues['sorting']['busy']
      if recall? || !@queues['sorting']['pending']
        @queues['sorting']['pending'] = true
        setTimeout () =>
          @processSorting(true)
        , 100
    else
      @queues['sorting']['busy'] = true
      @queues['sorting']['pending'] = false
      data = @queues['sorting']['next']
      @queues['sorting']['next'] = null

      if data
        window.onbeforeunload = () ->
          return 'Database updating in progress!'
        @collection.reorder(data).done () =>
          @queues['sorting']['busy'] = false
          window.onbeforeunload = undefined
          @folder.set('assets_sort_order', '')
      else
        @queues['sorting']['busy'] = false

  beforeClose: () ->
    if @queues['sorting']['busy'] || @queues['sorting']['pending']
      confirm 'Database updating in progress! Are you really want close the popup?'

  handleSorting: () ->
    $assets = @$('.assets-sort-list .row')
    data = _.map $assets, (item, index) ->
      { id: $(item).data('id'), position: $assets.size() - index }
    @queues['sorting']['next'] = data
    setTimeout () =>
      @processSorting()
    , 1
