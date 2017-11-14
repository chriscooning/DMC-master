class DMC.Views.Shared.Folder.List extends DMC.Views.Base

  initialize: ->
    @setElement $("#folders-list")
    @listenTo @collection, 'add', @addOne
    @listenTo @collection, 'sort', @reorder
    @listenTo @collection, 'remove', @removeOne

  render: ->
    @clearList()
    @addAll()
    @

  addOne: (model)=>
    view = new DMC.Views.Shared.Folder.Item(model: model).render()
    @renderElementToList(view.el)
    @checkFolderListEmptiness()

  addAll: ->
    @collection.each @addOne

  reorder: ->
    #hack for current active folder to be restored after sorting
    active_id = @$('.active a').data('id')
    @clearList()
    @addAll()
    @$("a[data-id=#{active_id}]").parent().addClass('active')

  renderElementToList: ($el)-> @$el.append $el

  removeOne: -> @checkFolderListEmptiness()

  clearList: -> @$el.empty()

  checkFolderListEmptiness: ->
    if @collection.length > 0
      $("#no-folders").fadeOut()
    else
      $("#no-folders").fadeIn()
