window.subdomainUrl = (url)->
  if window.subdomain
    "/#{window.subdomain}" +  url
  else
    url