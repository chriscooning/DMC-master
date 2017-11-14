class DMC.Views.Backend.Analytics.PreviewModal extends DMC.Views.Base
  template: JST['templates/backend/analytics/preview_modal']
  className: 'modal fade'

  events:
    'shown.bs.modal': 'afterOpening'
    'hidden.bs.modal': 'afterClose'

  render: ->
    @$el.html @template(@model.attributes)
    @$el.modal()
    @

  close: (options = {silently: false})->
    @silently = options['silently']
    @$el.modal('hide')

  afterClose: ->
    @$el.remove()
    @trigger('destroyed') unless @silently

  afterOpening: ->
    if !!@model.get('is_video')
      jwplayer("clipplayer").setup
        playlist: [
          image: @model.get('thumb_url')
          sources: [{
              file: @model.smil_manifest()
            },{
              file: @model.get('m3u8_url')
            }
          ]
        ]
        aspectratio: '16:9'
        flashplayer: "/jwplayer.flash.swf"
        primary: "html5"
        fallback: true
        width: '100%'