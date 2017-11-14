$.fn.serializeObject = ->
  result = {}
  a = @serializeArray()
  $.each a, ->
    if result[@name]
      if !result[@name].push
        result[@name] = [result[@name]]
        result[@name].push(@value || '')
     else
        result[@name] = @value || '';
  
  @find('select[data-integer]').each (i, el)-> result[el.name] = parseInt(result[el.name])
  _.each @find(":checkbox").not(":checked"), (el)-> 
    result[el.name] = false
  result