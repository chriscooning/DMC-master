class DMC.Views.Backend.Asset.QuickLinkModal extends DMC.Views.Shared.Form.Base
  template: JST['templates/backend/assets/quick_link_modal']
  modelFormSelector: '.asset-attributes'

  events:
    'shown.bs.modal': 'afterOpen'
    'hidden.bs.modal': 'afterClose'
    'click .save': 'save'
    'click .generate': 'generate'
    'switchChange.bootstrapSwitch #quicklink_should_expire' : 'toggleSwitch'

  afterOpen: ->
    currentDate = new Date()
    setDate = @model.get('quicklink_valid_to')

    # Instantiate the datepicker
    @$(".datetime").datepicker
      dateFormat: 'yy-mm-dd'
      minDate: currentDate

    # If a date is set then format and set it
    if setDate
      setTo = setDate.slice(0, setDate.indexOf("T"))
      @$(".datetime").datepicker("setDate", setTo)

    # If there is no quicklink defined, automatically generate one
    if !@model.get('quicklink_url')?
      @generate()

    # Instantiate switches for the quicklink settings
    @$('#quicklink_should_expire, #quicklink_downloadable').bootstrapSwitch()

  toggleSwitch: ->

    # Get the new value of the switch
    newValue = @$("#quicklink_should_expire").bootstrapSwitch('state')

    # Reset the valid to date (it shouldn't matter which way it is)
    @$("#quicklink_valid_to").val("")

    # Toggle the visibility of the date picker input
    @$(".date-picker-group").toggleClass('hidden', !newValue)

  generate: ->
    formData = { quicklink_valid_to: @$(".datetime").val() }
    $.post window.subdomainUrl("/assets/#{@model.get('id')}/generate_quicklink"), formData, (data)=>
      @model.set('quicklink_url', data.link)
      @$("#quicklink-field strong").html(data.link)
      @$(".preview-btn").removeClass("hidden").attr('href', @model.get('quicklink_url'))

  save: ->
    attributes = @$(@modelFormSelector).serializeObject()
    @model.save attributes,
      success: (model, result)=>
        if result.errors
          _.each result.errors, @renderErrors
        else
          @close()
          swal 'Saved!', 'Your quickling settings have been saved.', 'success'
          
      error: (model, xhr)=>
        @handleErrors(xhr)
