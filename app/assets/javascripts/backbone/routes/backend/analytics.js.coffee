class DMC.Routers.Backend.Analytics extends Backbone.Router

  routes:
    '!': 'index'
    '!/events/:id': 'showEventsAsset'
    '!/downloads/:id': 'showDownloadsAsset'
    '!uploader': 'uploader'

  initialize: (options)->
    super
    @events_collection = options['events_collection']
    @downloads_collection = options['downloads_collection']

  index: ->
    @modal.close() if @modal

  showEventsAsset: (id)->
    return unless @events_collection && model = @events_collection.get(id)
    @modal = new DMC.Views.Backend.Analytics.PreviewModal(model: model).render()
    @listenToOnce @modal, 'destroyed', => @navigate("!")

  showDownloadsAsset: (id)->
    return unless @downloads_collection && model = @downloads_collection.get(id)
    @modal = new DMC.Views.Backend.Analytics.PreviewModal(model: model).render()
    @listenToOnce @modal, 'destroyed', => @navigate("!")

  # note: uploader method shared between several routers.
  uploader: ->
    modal = new DMC.Views.Backend.Modals.AssetUploader()
    current_location = Backbone.history.fragment || '!'
    current_location = '!' if current_location == '!uploader'
    @listenToOnce modal, 'destroyed', () -> Backbone.history.navigate(current_location)
    modal.render().show()
