class DMC.Views.Shared.Form.Base extends DMC.Views.Base
  className: 'modal fade'

  events:
    'hidden.bs.modal': 'afterClose'
    'click a.save': 'save'

  render: ->
    @$el.html @template(@model.attributes)
    @$el.modal()
    @

  save: ->
    attributes = @$(@modelFormSelector).serializeObject()
    @model.save attributes,
      success: (model, result)=>
        if result.errors
          _.each result.errors, @renderErrors
        else
          @close()
      error: (model, xhr)=>
        @handleErrors(xhr)

  close: (options = {silently: false})->
    @silently = options['silently']
    @$el.modal('hide')

  afterClose: ->
    @$el.remove()
    @trigger('destroyed') unless @silently

  handleErrors: (xhr)->
    return unless xhr && xhr.responseJSON
    return unless xhr.responseJSON.errors
    _.each xhr.responseJSON.errors, @renderErrors

  clearErrors: ->
    @$(".error").remove()
    @$(".has-error").removeClass('has-error')

  renderErrors: (errors = [], field_name = '')=>
    @clearErrors()

    $field = @$("[name='#{field_name}']")
    $error = $ '<span/>',
      class: 'help-block error'
      text: if $.isArray(errors) then  errors.join(' ') else errors

    $field.after $error
    $field.parents('.form-group').addClass('has-error')