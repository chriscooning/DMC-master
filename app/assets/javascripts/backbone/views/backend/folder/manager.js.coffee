class DMC.Views.Backend.Folder.Manager extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/folder/manager']
  itemTemplate: JST['templates/backend/folder/manager_item']

  events:
    'hidden.bs.modal': 'afterClose'
    'click .add': 'add'
    'click .delete': 'delete'

  initialize: (options)->
    super
    @listenTo @collection, 'remove', @remove
    @gallery_id = @collection.gallery_id
    @

  render: ->
    @$el.html @template()
    @addAll()
    @$('.manage-folder-list').sortable
      handle: 'span.glyphicon'
      items: "> .row"
      update: (e, ui)=>
        order = {}
        @$('.manage-folder-list .row').each (i, el)=>
          id = $(el).data('id')
          order[id] = i + 1
          @collection.get(id).set(position: i + 1)
        $.post "/galleries/#{@gallery_id}/folders/reorder", order: order
        @collection.sort()
    @$('.manage-folder-list').disableSelection()

    @$el.modal()
    @

  add: ->
    attributes = @$('.folder-attributes').serializeObject()
    model = new DMC.Models.Folder(attributes)
    @collection.add model
    model.save {},
      success: =>
        @addOne(model)
        @$('.new-folder input').val('')
        @clearErrors()
      error: (model, xhr)=>
        model.destroy()
        @handleErrors(xhr)

    false

  remove: (model)->
    model.manager_view.remove() if model.manager_view

  addOne: (model)=>
    $template = $ @itemTemplate(model.attributes)
    model.manager_view = $template
    @$('.manage-folder-list').append $template

  addAll: ->
    @collection.all @addOne

  delete: (e)->
    $el = $(e.target)
    self = @
    swal {
      title: 'Are you sure you want to delete this folder?'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Yes, delete it!'
      closeOnConfirm: false
    }, ->
      model = self.collection.get $el.data('id')
      model.destroy() if model
      swal 'Deleted!', 'Your folder has been deleted.', 'success'
      return

    false
