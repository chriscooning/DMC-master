class DMC.Libs.BaseModel extends Backbone.Model
  modelAttributes: []
  methodAttributes: []

  withMethodAttribures: ->
    attributes = _.clone(@attributes)
    _.each @methodAttributes, (method)=>
        attributes[method] = @[method]()

    attributes

  toJSON: (options = {}) ->
    default_options = { applyRoot: true, filter: true }
    options = _.defaults(options, default_options)

    if options['filter'] && !@accessibleAttributes
      console.error("Define accessible attributes for #{@constructor.name}")

    json = _.clone(@attributes)
    result = {}
    if options['filter']
      _.each @methodAttributes, (method)=>
        json[method] = @[method]()
      _.each @modelAttributes, (attr)=>
        json[attr] = @get(attr)
      _.each @attributes, (value, key)=>
        if !_.include @accessibleAttributes, key
          delete json[key]
      , this

    if options['applyRoot'] && @paramRoot
      result[@paramRoot] = json
    else
      result = json
      
    result

  asJSON: ->
    @toJSON(applyRoot: false)