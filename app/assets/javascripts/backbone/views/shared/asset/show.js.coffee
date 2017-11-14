class DMC.Views.Shared.Asset.Show extends DMC.Views.Base
  className: 'modal fade'
  template: JST['templates/shared/assets/show']

  events:
    'shown.bs.modal': 'afterOpening'
    'hidden.bs.modal': 'afterClose'
    'click .show_previous_asset': 'showAnotherAsset'
    'click .show_next_asset': 'showAnotherAsset'

  render: ->
    $("body").addClass('modal-open')
    templateArgs = _.extend({}, @model.withMethodAttribures(), @scrollingAttributes())
    @$el.html @template(templateArgs)
    @$el.addClass('pdf-preview') if @model.get('is_pdf')
    @$el.modal()
    @

  close: (options = {silently: false})->
    @silently = options['silently']
    @$el.modal('hide')

  afterClose: ->
    $("body").removeClass('modal-open')
    jwplayer('clipplayer').remove() if @$el.find('#clipplayer') && jwplayer('clipplayer').remove
    @$el.remove()
    @trigger('destroyed') unless @silently

  afterOpening: ->

    if @model.get('is_pdf')
      pdfObject = new PDFObject(url: @model.get('pdf_preview_url')).embed('pdf-preview')
      return

    if !!@model.get('is_audio')
      playlist = _.map((@model.get('audio_urls') || []), (file_url) -> { file: file_url })
      jwplayer("clipplayer").setup
        playlist: playlist
        flashplayer: "/jwplayer.flash.swf"
        primary: "html5"
        fallback: true
        width: '100%'
        height: 30

    if !!@model.get('is_video') && !!@model.get('processed')
      jwplayer("clipplayer").setup
        playlist: [
          image: @model.get('thumb_url')
          sources: [{
              file: @model.smil_manifest()
            },{
              file: @model.get('m3u8_url')
            },{
              file: @model.get('video_urls')['mp4_360p']
            }
          ]
        ]
        aspectratio: '16:9'
        flashplayer: "/jwplayer.flash.swf"
        primary: "html5"
        fallback: true
        width: '100%'

  scrollingAttributes: () ->
    collection = @model.collection
    index = collection.indexOf(@model)
    return {} if index == -1 || collection.length <= 1

    if index + 1 >= collection.length
      { previous_asset_id: collection.at(index - 1).id }
    else if index == 0
      { next_asset_id: collection.at(index + 1).id }
    else
      { previous_asset_id: collection.at(index - 1).id, next_asset_id: collection.at(index + 1).id }

  # no matter, next asset or previous
  # load asset and re-render inner data
  showAnotherAsset: (e) =>
    e.preventDefault()
    jwplayer('clipplayer').remove() if @$el.find('#clipplayer') && jwplayer('clipplayer').remove
    asset_id = $(e.target).data('id')
    asset = @model.collection.get(asset_id)
    if asset
      @model = asset
      @render()
      @afterOpening()
