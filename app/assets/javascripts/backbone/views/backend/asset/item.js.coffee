class DMC.Views.Backend.Asset.Item extends DMC.Views.Shared.Asset.Item
  template: JST['templates/backend/assets/item']

  initialize: (options)->
    super
    @model.fetch_video()
    @