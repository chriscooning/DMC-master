class DMC.Views.Backend.Asset.AnalyticsModal extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/assets/analytics_modal']

  events:
    'shown.bs.modal': 'afterOpen'
    'hidden.bs.modal': 'afterClose'
    'click .report': 'loadAnalytics'

  initialize: (options = {})->
    super
    @

  render: ->
    super
    @grapherView = new DMC.Views.Backend.Analytics.Grapher(
      graph: @$('#graph'), filter: @$(".filters"), loading: @$("#loading"), id: @model.get('id'), el: @$el
    ).render()
    @

  afterOpen: ->
    @loadAnalytics()

  loadAnalytics: ->
    @grapherView.loadAnalytics()

