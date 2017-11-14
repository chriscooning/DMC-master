class DMC.Views.Backend.Gallery.List extends DMC.Views.Base

  initialize: (options = {})->
    super
    @setElement $("#gallery-list tbody")
    @listenTo @collection, 'add', @addOne

  render: ->
    @$el.empty()
    @addAll()
    @$el.sortable
      handle: 'span'
      helper: (e, tr)->
        $originals = tr.children()
        $helper = tr.clone()
        $helper.children().each (index)->
          $(this).width($originals.eq(index).width())
        $helper
      update: (e, ui)=>
        order = {}
        @$('tr').each (i, el)->
          id = $(el).data('id')
          order[id] = i + 1
        $.post @reorderUrl(), order: order

    @$el.disableSelection()
    @

  addOne: (model)=>
    view = new DMC.Views.Backend.Gallery.Item(model: model).render()
    @$el.append view.el

  addAll: ->
    @collection.each @addOne

  reorderUrl: -> window.subdomainUrl("/galleries/reorder")

