class DMC.Views.Backend.Folder.Form extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/folder/form']
  modelFormSelector: '.folder-attributes'
  galleryChanged: false

  events: _.extend({
      'click #password': 'togglePasswordField'
    }, DMC.Views.Shared.Form.Base.prototype.events)

  render: ->
    @listenTo @model, 'change:gallery_id', -> @galleryChanged = true
    attributes = _.extend @model.attributes,
      galleries: window.myGalleries
      per_pages: [8, 16, 24]
    @$el.html @template(attributes)
    @$el.modal()
    @

  togglePasswordField: (e)->
    $e = $(e.target)
    @$("#password-field").toggleClass 'hide', !$e.is(":checked")

  afterClose: ->
    return super unless @galleryChanged
    window.location.href = "/galleries/#{@model.get('gallery_id')}/#!folders/#{@model.get('id')}"
