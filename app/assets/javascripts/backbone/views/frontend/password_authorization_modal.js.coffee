class DMC.Views.Frontend.PasswordAuthorizationModal extends DMC.Views.Shared.Form.Base
  template: JST['templates/frontend/password_authorization_modal']

  events: _.extend({
    "submit form": 'save'
  }, DMC.Views.Shared.Form.Base.prototype.events)
  url: ->
    "/galleries/#{@gallery_id}/authenticate"

  initialize: (options)->
    super
    @desired_link = options['desired_link']
    @gallery_id = options['gallery_id']
    @

  render: ->
    @$el.html @template()
    @$el.modal()
    @

  save: ->
    @clearErrors()
    attributes = @$('.authorization-attributes').serializeObject()
    $.ajax
      url: @url()
      method: 'POST'
      data: attributes
      success: @processResponce
    false
    
  processResponce: (data)=>
    if data.errors
      _.each(data.errors, @renderErrors)
    else
      @close(silently: true)
      window.location = @desired_link
      false