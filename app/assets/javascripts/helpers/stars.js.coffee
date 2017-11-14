$ ->
  $(".home-intro, .pricing-wrapper").mousemove (e) ->
    amountMovedX = (e.pageX * -.1 / 6)
    amountMovedY = (e.pageY * -.5 / 6)
    $(this).css "background-position", amountMovedX + "px " + amountMovedY + "px"

$ ->
  $(".glow").mousemove (e) ->
    amountMovedX = (e.pageX * -.03 / 20)
    amountMovedY = (e.pageY * .03 / 20)
    $(this).css "background-position", amountMovedX + "px " + amountMovedY + "px"