class DMC.Views.Shared.Asset.Search extends DMC.Views.Base

  events:
    'click btn': 'startSearch'

  startSearch: ->
    query = $("#search").val()


