jQuery(document).ready ($) ->
  $(window).stellar
   hideDistantElements: false
   horizontalScrolling: false
   verticalOffset: 240

  $("body").mousemove (e) ->
    
    offset = $(this).offset()
    xPos = e.pageX - offset.left
    yPos = e.pageY - offset.top
    
    mouseXPercent = Math.round(xPos / $(this).width() * 4)
    mouseYPercent = Math.round(yPos / $(this).height() * 5)
    
    $(".clouds").each ->
      diffX = $("body").width() - $(this).width()
      diffY = $("body").height() - $(this).height()
      myX = diffX * (mouseXPercent / 100)
      myY = diffY * (mouseYPercent / 100)
      cssObj =
        left: myX + "px"
        top: myY + "px"
      
      $(this).animate
        left: (600) + myX
        bottom: (-100) + myY
      ,
        duration: 50
        queue: false
        easing: "linear"

    $(".clouds_bg").each ->
      diffX = $("body").width() - $(this).width()
      diffY = $("body").height() - $(this).height()
      myX = diffX * (mouseXPercent / 300)
      myY = diffY * (mouseYPercent / 300)
      cssObj =
        left: myX + "px"
        top: myY + "px"
      
      $(this).animate
        left: (-700) + myX
        bottom: (-40) + myY
      ,
        duration: 60
        queue: false
        easing: "linear"

  $(".home-usage").waypoint ( ->
    $('.navbar').toggleClass('navbar-inverse').toggleClass('navbar-default')
  ),
    offset: "20%"

  $('.pages-home.container').waypoint ( ->
    $('.navbar').toggleClass('opacity')
  ),
    offset: "1"