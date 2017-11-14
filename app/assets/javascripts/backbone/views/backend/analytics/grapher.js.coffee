class DMC.Views.Backend.Analytics.Grapher extends DMC.Views.Base

  events:
    'click .report': 'loadAnalytics'
    'change .datetime': 'loadAnalytics'
    'click .graph-types': 'switchGraphs'

  initialize: (options = {})->
    @setElement options['el']
    @graphPane = options['graph']
    @filterPane = options['filter']
    @loadingPane = options['loading']
    @assetId = options['id']
    @

  render: ->
    @filterPane.find(".datetime").datepicker()
    @

  url: ->
    url = if @assetId then "/analytics/#{@assetId}" else "/analytics"
    window.subdomainUrl(url)

  switchGraphs: (e)->
    return unless @downloads
    @filter = null
    @renderGraph(@downloads)

  filters: ->
    @filter ||=
      downloads: @filterPane.find('#graph-downloads').is(':checked')

  renderGraph: (downloads)->
    data = []
    if @filters()['downloads']
      data.push
        type: 'line'
        lineThickness: 2
        name: 'Downloaded'
        markerType: 'square'
        dataPoints: downloads
        color: 'blue'
    chart = new CanvasJS.Chart('graph',
        height: 300
        creditText: ''
        axisX:
          gridColor: "silver"
          tickColor: "silver"
          valueFormatString: "DD/MMM"
        theme: "theme2"
        axisY:
          gridColor: "silver"
          tickColor: "silver"
          minimum: 0
        toolTip:
          shared: true
        legend:
          verticalAlign: "center"
          horizontalAlign: "right"
        data: data
      )
    @graphPane.show()
    setTimeout (->
      chart.render()
      return
    ), 500

  loadAnalytics: (e)->
    e.preventDefault() if e
    e.stopPropagation() if e
    @loadingPane.show()
    @graphPane.hide()
    data =
      from: @$("#from-filter").val()
      to: @$("#to-filter").val()

    $.get @url(), data, (result)=>
      @loadingPane.hide()
      @downloads = []
      for value in result
        @downloads.push { x: new Date(value['date']), y: value['downloads'] }

      @renderGraph(@downloads)
    , 'json'
