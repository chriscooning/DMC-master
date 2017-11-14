class DMC.Views.Shared.SortSelector extends DMC.Views.Base
  template: JST['templates/shared/sort_selector']

  events: _.extend({
    "change select" : 'update_sort_order'
  }, DMC.Views.Base::events)

  render: () ->
    if @collection && @collection.folder
      @$el.html(@template(
        folder_id:  @collection.folder.id
        sort_order: @collection.folder.get('assets_sort_order')
      ))
    else
      @$el.empty()

  update_sort_order: (e) ->
    if @processing
      console.log('sorry, sort in progress')
    else
      @processing = true
      @collection.sort($(e.target).val())
      @listenToOnce(@collection, 'reorder', () =>
        @processing = false
        @$el.find('#sort-select').val(@collection.folder.get('assets_sort_order'))
      )
