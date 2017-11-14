window.initRetrieveAuthTokenButton = () ->
  $('#retrieve-auth-code-btn').click (e) ->
    e.preventDefault()
    link_button = $(e.target).attr('disabled', 'disabled').html('Generating...')
    container   = link_button.closest('.tab-pane')
    $.ajax
      url: link_button.data('url')
      method: 'post'
      contentType: 'application/json'
      success: (xhr, options) ->
        container.find('.has-auth-code.hidden').removeClass('hidden')
        container.find('.has-auth-code .auth-token').html(xhr['token'])
      complete: () ->
        link_button.html('Regenerate API Key').removeAttr('disabled')
