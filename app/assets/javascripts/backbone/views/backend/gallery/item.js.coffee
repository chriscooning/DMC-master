class DMC.Views.Backend.Gallery.Item extends DMC.Views.Base
  tagName: 'tr'
  template: JST['templates/backend/gallery/item']

  events:
    'click .edit': 'edit'
    'click .delete': 'delete'
    'click .toggle-first': 'toggleFirst'

  initialize: (options)->
    super
    @model.view = @
    @listenTo @model, 'sync', @render
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @delete
    @

  render: ->
    @$el.html @template(@model.asJSON())
    @$el.data('id', @model.get('id'))
    @

  edit: ->
    new DMC.Views.Backend.Gallery.Form(model: @model).render()

  delete: ->
    self = @
    swal {
      title: 'Are you sure you want to delete this gallery?'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Yes, delete it!'
      closeOnConfirm: false
    }, ->
      self.stopListening()
      self.$el.remove()
      self.model.destroy()
      swal 'Deleted!', 'Your gallery has been deleted.', 'success'
      return

  toggleFirst: ->
    return if !@model
    @model.toggleFirst()
