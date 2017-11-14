$ ->
  $.each window.flashes, window.renderFlashMessage
    

window.renderFlashMessage = (type, content)->
  type = if type == 'notice'
    'alert-success'
  else
    'alert-danger'

  attributes = 
    type: type 
    content: content

  $template = $(JST['templates/flash'](attributes)).hide()
  if $("#body .navbar").length
    $("#body .navbar").prepend $template
  else 
    $('.regular-content').prepend $template
  $template.slideDown 'fast'

  $template.on 'click', ->
    $template.slideUp 'fast'

  setTimeout ->
    $template.slideUp 'fast'
  , 6000