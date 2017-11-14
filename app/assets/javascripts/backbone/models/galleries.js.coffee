class DMC.Models.Gallery extends DMC.Libs.BaseModel
  modelAttributes: ['id', 'name', 'visible', 'enable_password', 'enable_invitation_credentials',
                    'editable', 'destroyable', 'gallery_message']
  accessibleAttributes: ['name', 'visible', 'enable_password', 'enable_invitation_credentials',
                         'password', 'url', 'show_first', 'editable', 'destroyable', 'gallery_message']
  methodAttributes: ['url']

  paramRoot: 'gallery'

  defaults:
    visible: true

  toggleFirst: (successCallback) ->
    model = @
    (@sync || Backbone.sync).call(@, null, @, {
      type: "POST",
      url: window.subdomainUrl("/galleries/#{@id}/toggle_first"),
      dataType: 'json'
    }).always((data) ->
      model.collection.invoke('set', { show_first: false })
      model.set(show_first: data.show_first)
      successCallback.call(model, data) if successCallback
    )

  validate: (attrs, options) ->
    if !attrs.name
      return ("name can't be blank")

class DMC.Collections.Galleries extends Backbone.Collection
  model: DMC.Models.Gallery

  url: -> window.subdomainUrl("/galleries")
