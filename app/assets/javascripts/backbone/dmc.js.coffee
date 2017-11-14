#= require_self
#= require_tree ./libs
#= require_tree ./models
#= require      ./views/base
#= require_tree ./views/shared
#= require      ./views/frontend/password_authorization_modal
#= require_tree ./views/frontend
#= require_tree ./views/backend
#= require_tree ./routes/shared
#= require_tree ./routes/frontend
#= require_tree ./routes/backend

window.DMC =
  Models: {}
  Libs: {}
  Collections: {}
  Views:
    Shared:
      Asset: {}
      Folder: {}
      Form: {}
    Frontend:
      Folder: {}
      Asset: {}
    Backend:
      Gallery: {}
      Folder: {}
      Asset: {}
      Modals: {}
      Analytics: {}
  Routers:
    Shared: {}
    Frontend: {}
    Backend: {}
