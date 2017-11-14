class DMC.Views.Backend.Asset.EmbeddingModal extends DMC.Views.Base
  className: 'modal fade'
  template: JST['templates/backend/assets/embedding_modal']

  events:
    'hidden.bs.modal': 'afterClose'
    'change input': 'generateCode'
    'click .generate': 'generateCode'

  render: ->
    @$el.html @template(@model.attributes)
    @width = @$("#video-width")
    @height = @$("#video-height")
    @autoplay = @$("#autoplay")
    @sharing = @$("#sharing")
    @$el.modal()
    @

  generateCode: ->
    autoplay = @autoplay.is(":checked")
    width = if @width.val() then "width='#{@width.val()}'" else ''
    height = if @height.val() then "height='#{@height.val()}'" else ''
    sharing = @sharing.val()
    url = "//#{window.baseUrl}/e/#{@model.get('embedding_hash')}?autoplay=#{autoplay}&sharing=#{sharing}"
    code = "<iframe frameborder='0' allowfullscreen='allowfullscreen' webkitallowfullscreen='webkitallowfullscreen' mozallowfullscreen='mozallowfullscreen' #{width} #{height} src='#{url}' />"
    @$("#embedding-code").val code
    false

  afterClose: ->
    @$el.remove()
    @trigger('destroyed') unless @silently
