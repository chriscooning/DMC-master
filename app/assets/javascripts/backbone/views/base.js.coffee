class DMC.Views.Base extends Backbone.View
  cleanup: =>
    @undelegateEvents()
    @stopListening()
    @unbind()