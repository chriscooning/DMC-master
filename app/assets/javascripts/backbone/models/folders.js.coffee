class DMC.Models.Folder extends DMC.Libs.BaseModel
  modelAttributes: ['id', 'name', 'hide_folder', 'enable_password',
                    'default_per_page', 'editable', 'destroyable', 'can_create_assets']
  accessibleAttributes: ['name', 'hide_folder', 'enable_password', 'assets_sort_order',
                        'password', 'hide_title', 'hide_description', 'gallery_id', 'default_per_page',
                        'editable', 'destroyable', 'can_create_assets']
  paramRoot: 'folder'

  is_title_visible: -> !@get('hide_title')

  is_description_visible: -> !@get('hide_description')

  validate: (attrs, options) ->
    if !attrs.name
      return ("name can't be blank")

class DMC.Collections.Folders extends Backbone.Collection
  model: DMC.Models.Folder

  comparator: 'position'

  initialize: (models, options)->
    super
    @gallery_id = options['gallery_id']
    @

  url: -> window.subdomainUrl("/galleries/#{@gallery_id}/folders")
