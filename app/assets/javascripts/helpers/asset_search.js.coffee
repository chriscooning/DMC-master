$ ->
  $("#search-container form").on 'submit', ->
    query = $("#search").val()
    Backbone.history.navigate("!search/#{query}", trigger: true)
    false

