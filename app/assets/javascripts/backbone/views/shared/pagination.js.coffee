class DMC.Views.Shared.Pagination extends DMC.Views.Base
  template: JST['templates/shared/pagination']

  events:
    'click a': 'paginate'
    'change select': 'changePaginatePer'

  initialize: (options)->
    super
    @urlRoot = options['urlRoot']
    @

  changePaginatePer: (e)->
    @collection.perPage = parseInt $(e.target).val()
    @collection.currentPage = 1
    @collection.fetch(reset: true)
    window.DMC.route.navigate("!folders/#{@collection.folder_id}")

  render: ->
    attrs = _.extend @collection.info(), urlRoot: @urlRoot
    @$el.html @template(attrs)
    @

