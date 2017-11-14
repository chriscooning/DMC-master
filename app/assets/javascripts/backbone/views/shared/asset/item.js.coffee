class DMC.Views.Shared.Asset.Item extends DMC.Views.Base
  className: 'col-md-3 asset-item'
  template: JST['templates/frontend/assets/item']

  events:
    'click .delete': 'delete'
    'show.bs.dropdown .dropdown': 'toggleDropDownPosition'

  initialize: (options)->
    super
    @folder = options['folder']
    @model.view = @
    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove
    @

  render: ->
    attributes = _.extend @model.withMethodAttribures(),
      is_title_visible: @folder.is_title_visible()
      is_description_visible: @folder.is_description_visible()
    @$el.html @template(attributes)
    @

  delete: ->
    self = @
    swal {
      title: 'Are you sure?'
      text: 'ALL analytics information, quicklinks etc. related to the associated asset will be deleted.'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Yes, delete it!'
      closeOnConfirm: false
    }, ->
      self.model.destroy()
      swal 'Deleted!', 'Your asset has been deleted.', 'success'
      return

    false

  remove: ->
    @stopListening()
    @$el.remove()

  toggleDropDownPosition: (event) ->
    $target = $(event.target)
    $menu = $target.find('.dropdown-menu')
    togglerBY = $target.offset().top + $target.height()
    viewportBY = $(document).scrollTop() + $(window).height()

    if ((viewportBY > togglerBY) && ((viewportBY - togglerBY) > $menu.height()))
      $target.removeClass('dropup')
    else
      $target.addClass('dropup')
