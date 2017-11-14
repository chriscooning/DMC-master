class DMC.Views.Backend.Gallery.Form extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/gallery/form']
  modelFormSelector: '.gallery-attributes'

  events: _.extend({
      'click #password': 'tooglePasswordField'
    }, DMC.Views.Shared.Form.Base::events)

  tooglePasswordField: (e)->
    $e = $(e.target)
    @$("#password-field").toggleClass 'hide', !$e.is(":checked")

  close: ->
    @$el.modal('hide')

  afterClose: ->
    @model.destroy() if @model.isNew()
    super
