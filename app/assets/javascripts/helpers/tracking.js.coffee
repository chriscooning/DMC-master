window.trackEvent = (name, target_id, target_type = 'Asset')->
  $.post '/events', 
    event: 
      name: name
      target_id: target_id
      target_type: target_type