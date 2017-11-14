$ ->
  $("a#restrictions").on 'click', ->
    $("#restrictions-modal").clone().modal()
    false
$ ->
  return unless $("#gallery-list, #user-portal").length > 0
  $("a[data-password-required=true]").on 'click', (e)->
    e.stopPropagation()
    $this = $(e.target)
    new DMC.Views.Frontend.PasswordAuthorizationModal(desired_link: $this.attr('href'), gallery_id: $this.data('id')).render()
    false

  if window.ask_password_for
    $("a[data-password-required=true][data-id=#{ window.ask_password_for }]:first").click()

$ ->
  return unless $("#gallery-edit").length > 0
  $menu_list = $("#menu-links-list")

  checkLinksCount = ->
    show = $menu_list.find('.fields').not('.for-deletion').length < window.maximumMenuLinks
    $menu_list.find('a.add_nested_fields').toggle(show)

  checkLinksCount()

  $(document).on 'nested:fieldAdded:menu_links', ->
    checkLinksCount()

  $(document).on 'nested:fieldRemoved:menu_links', (e)->
    e.field.addClass('for-deletion')
    checkLinksCount()
      
    

  $menu_list.sortable
    handle: 'span.glyphicon.glyphicon-resize-vertical'
    items: '> .fields'
    update: (e, ui)->
      $("#menu-links-list .fields").each (i, el)->
        $el = $(el).find('.gallery_menu_links_position input')
        $el.val i + 1
