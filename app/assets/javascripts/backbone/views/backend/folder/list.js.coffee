class DMC.Views.Backend.Folder.List extends DMC.Views.Shared.Folder.List

  renderElementToList: ($el)-> @$el.find('#manage-folders').before($el)

  clearList: -> @$el.find('.folder-item').remove()
