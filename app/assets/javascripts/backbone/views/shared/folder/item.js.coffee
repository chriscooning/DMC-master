class DMC.Views.Shared.Folder.Item extends DMC.Views.Base
  tagName: 'li'
  className: 'folder-item'
  template: JST['templates/shared/folder/item']

  events:
    'click a': 'makeActive'
    'click .edit': 'edit'
    'click .delete': 'delete'
    'click span': 'editFolder'

  initialize: (options)->
    super
    @model.view = @
    @listenTo @model, 'change', @render
    # it seems, event 'destroy' called by destroy method only
    @listenToOnce @model, 'destroy', @deleteView
    @

  makeActive: ->
    @$el.parent().find('.active').removeClass('active')
    @$el.addClass('active')

  render: ->
    @$el.html @template(@model.attributes)
    @

  edit: ->
    new DMC.Views.Backend.Gallery.Form(model: @model).render()

  delete: ->
    if @model.isNew()
      @performDelete()
    else
      self = @
      swal {
        title: 'Are you sure you want to delete this folder?'
        type: 'warning'
        showCancelButton: true
        confirmButtonColor: '#DD6B55'
        confirmButtonText: 'Yes, delete it!'
        closeOnConfirm: false
      }, ->
        self.performDelete()
        swal 'Deleted!', 'Your folder has been deleted.', 'success'
        return

  performDelete: ->
    @stopListening()
    @$el.remove()
    @model.destroy()

  deleteView: () ->
    @$el.remove()

  editFolder: ->
    Backbone.history.navigate("!edit/#{@model.get('id')}", trigger: true)
    false
