class DMC.Models.PreviewAsset extends DMC.Libs.BaseModel
  modelAttributes: ['file_url', 'medium_url']

  accessibleAttributes: []

  smil_manifest: ->
    "/galleries/#{@get('gallery_id')}/folders/#{@get('folder_id')}/assets/#{@get('id')}/manifest.smil"


class DMC.Collections.PreviewAssets extends Backbone.Collection
  model: DMC.Models.PreviewAsset