class DMC.Routers.Backend.Gallery extends Backbone.Router
  routes:
    '!': 'index'
    '!new': 'new'
    '!uploader': 'uploader'

  initialize: (options)->
    @collection = options['collection']

  index: ->
    @modal.close() if @modal

  new: ->
    model = new DMC.Models.Gallery()
    @collection.add model
    @modal = new DMC.Views.Backend.Gallery.Form(model: model).render()
    @listenToOnce @modal, 'destroyed', => @navigate('!')

  # note: uploader method shared between several routers.
  uploader: ->
    modal = new DMC.Views.Backend.Modals.AssetUploader(galleries: @collection)
    current_location = Backbone.history.fragment || '!'
    current_location = '!' if current_location == '!uploader'
    @listenToOnce modal, 'destroyed', () -> Backbone.history.navigate(current_location)
    modal.render().show()
