$ ->
  return unless $("#api-console").length
  presets =
    token:
      type: 'POST'
      params: 
        email: 'user@example.com'
        password: 'password'
      url: '/api/v1/token.json'

    galleries:
      type: 'GET'
      params:
        user_token: ''
      url: '/api/v1/galleries.json'
    
    folders:
      type: 'GET'
      params: 
        user_token: ''
        gallery_id: ''
      url: '/api/v1/folders.json'

    create_invite:
      type: 'POST'
      params:
        user_token: ''
        email: 'customer@example.com'
        gallery_ids: ''
      url: '/api/v1/invites.json'

    destroy_invite:
      type: 'DELETE'
      params:
        user_token: ''
        email: 'old_customer@example.com'
      url: '/api/v1/invites'

  $presetSelector = $("#presets")
  $typeSelector = $("#type")
  $urlInput = $("#url")
  $paramsBlock = $("#additional-params")
  $statusCode = $("#status .result")
  $statusLabel = $("#status .label")
  $sendButton = $("#send")
  $resultField = $("#result")
  baseUrl = $urlInput.data('base')

  $presetSelector.on 'change', ->
    selected = $presetSelector.val()
    preset = presets[selected]
    return unless preset
    $urlInput.val baseUrl + preset['url']
    $typeSelector.find('option').attr('selected', false)
    $typeSelector.find("option[value=#{preset['type']}]").attr('selected', true)
    return unless preset['params']
    counter = 0
    $paramsBlock.find('input').val('')
    $.each preset['params'], (k, v)->
      $paramsBlock.find("input[name='key[#{counter}]']").val(k)
      $paramsBlock.find("input[name='value[#{counter}]']").val(v)
      counter++

  $presetSelector.change()

  getParams = ->
    result = if $.inArray($typeSelector.val(), ['GET', 'POST']) > -1
      {}
    else
      { _method: $typeSelector.val() }

    $paramsBlock.find('.row').each (i, el)->
      $el = $(el)
      key = $el.find('[name*="key"]').val()
      value = $el.find('[name*="value"]').val()
      return true unless key || value
      result[key] = value

    result

  getRequestType = ->
    if $.inArray($typeSelector.val(), ['GET', 'POST']) > -1
      $typeSelector.val()
    else
      'POST'

  $sendButton.on 'click', ->
    return unless $urlInput.val()    
    $.ajax
      url: $urlInput.val()
      type: getRequestType()
      dataType: 'json'
      data: getParams()
      success: (response, status, xhr)->
        $statusLabel.removeClass('label-danger')
        $statusCode.text "#{xhr.status} #{xhr.statusText}"
        result = JSON.stringify(response, undefined, 2)
        $resultField.html result

      error: (xhr)->
        $statusLabel.addClass('label-danger')
        $resultField.html ''
        if xhr.status > 0
          $statusCode.text "#{xhr.status} #{xhr.statusText}"
        else
          $statusCode.text "400 Bad Request"
        return if xhr.responseText is ''
        json = JSON.parse(xhr.responseText)
        result = JSON.stringify(json, undefined, 2)
        $resultField.html result
        
        


