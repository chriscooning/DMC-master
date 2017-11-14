$(document).ready ->

  windowHeight = $(window).height()
  windowWidth = $(window).width()
  sidebarHeight = $(document).height() - $('#navbar').height() - $('#footer-backend').height()

  $('#accordion-inner').collapse()

  if $("ul.settings-tabs").length > 0 && window.location.hash != ''
    $("ul.settings-tabs a[href='#{window.location.hash}']").tab('show')

  $(".navbar-brand img").load ->
    navbarHeight = $("#navbar").height()
    lineHeight = navbarHeight - parseInt($("#navbar .navbar-nav > li > a").css("padding-top")) - parseInt($("#navbar .navbar-nav > li > a").css("padding-bottom"))
    $("#navbar .navbar-nav > li > a").css "line-height": lineHeight + 'px'

    $('.frontend #content').css "padding-top", navbarHeight

  if $('.settings-security.backend').length > 0
    updatePasswordFieldVisibility = () ->
      $password_input = $('#account_subdomain_password')
      if $('#account_enable_subdomain_password').is(':checked')
        $password_input.removeAttr('disabled').closest('.form-group').removeClass('hidden')
      else
        $password_input.attr('disabled', true).closest('.form-group').addClass('hidden')

    $('#account_enable_subdomain_password').on('change', updatePasswordFieldVisibility)
    updatePasswordFieldVisibility()

  $('.uploader-link').on('click', (e) ->
    if !Backbone.History.started
      e.preventDefault()
      showAssetUploader()
    else
      # @listenToOnce modal, 'destroyed', () -> Backbone.history.navigate("!")
      # do nothing, '#uploader' should be catched by routers
  )

  # backbone router imitation
  # show uploader by hash
  # if window.location && window.location.hash && window.location.hash == '#!uploader' && $('.modal:visible').length == 0
  #   _.delay(window.showAssetUploader, 300)

window.showAssetUploader = (options = {}) ->
  if window.selected_gallery_id
    options.gallery_id = window.selected_gallery_id
  modal = new DMC.Views.Backend.Modals.AssetUploader(options)

  current_hash = window.location.hash || '#!'
  current_hash = '!' if current_hash == '#!uploader'
  modal.once('destroyed', () -> window.location.hash = current_hash)

  modal.render().show()
  window.location.hash = '#!uploader'

# move to separate module?
window.enablePermissionsAutofill = (selector, rolesData) ->
  # store data in binding
  roles = rolesData

  # store preselected values
  _.each($("input[name='user[permission_ids][]']"), (input) ->
    $checkbox = $(input)
    $checkbox.data('selected', $checkbox.is(':checked'))
  )

  # update preselected value
  $("input[name='user[permission_ids][]']").on('change', (e) ->
    $checkbox = $(e.currentTarget)
    $checkbox.data('selected', $checkbox.is(':checked'))
  )

  # update selected role permissions
  permissions = roles[$(selector).val()]
  _.each(permissions, (permission) ->
    $("#user_permission_ids_#{ permission.id }").prop('disabled', 'disabled').prop('checked', 'checked')
  )

  $(selector).on('change', (e) ->
    # restore previous state
    $("input[name='user[permission_ids][]']").prop('disabled', false)
    _.each($("input[name='user[permission_ids][]']"), (input) ->
      $(input).prop('checked', $(input).data('selected'))
    )

    # disable role permission and check them as selected
    permissions = roles[$(e.currentTarget).val()]
    _.each(permissions, (permission) ->
      $("#user_permission_ids_#{ permission.id }").prop('disabled', 'disabled').prop('checked', 'checked')
    )
    true
  )

window.enablePermissionsHelperLinks = (container) ->
  $(container).find("a[data-action='expand-all']").on('click', (e) ->
    e.preventDefault()
    $(container).find('.panel-collapse').collapse('show')
  )
  $(container).find("a[data-action='collapse-all']").on('click', (e) ->
    e.preventDefault()
    $(container).find('.panel-collapse').collapse('hide')
  )
  $(container).find("a[data-action='select-all']").on('click', (e) ->
    e.preventDefault()
    $(container).find('input[type=checkbox][id*=permission_ids]').prop('checked', true)
  )
  $(container).find("a[data-action='unselect-all']").on('click', (e) ->
    e.preventDefault()
    $(container).find('input[type=checkbox][id*=permission_ids]').prop('checked', false)
  )
