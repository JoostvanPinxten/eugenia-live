Spine = require('spine')
MovesPath = require('models/moves_path')
SimplifiesSegments = require('models/simplifies_segments')
LinkShape = require('models/link_shape')

# Should extend Element
class Link extends Spine.Model
  @configure "Link", "sourceId", "targetId", "segments", "shape", "propertyValues"
  @belongsTo 'drawing', 'models/drawing'
  
  # TODO duplication with Node (inherit from Element?)
  constructor: (attributes) ->
    super
    @k = v for k,v of attributes
    @updateSegments(attributes.segments) if attributes
    @initialisePropertyValues()

  initialisePropertyValues: ->
    # Don't call save() during initialisation, as this causes
    # duplicate Spine records to be created.
    @propertyValues or= {}
    @updatePropertyValuesWithDefaultsFromShape(false)
        
  getAllProperties: ->
    @updatePropertyValuesWithDefaultsFromShape(true)
    @propertyValues
  
  updatePropertyValuesWithDefaultsFromShape: (persist) ->
    for property,value of @defaultPropertyValues()
      # insert the default value unless there is already a value for this property
      @setPropertyValue(property,value,false) unless @hasPropertyValue(property)
    
    for property,value of @propertyValues
      # remove the current value unless this property is currently defined for this shape
      @removePropertyValue(property,false) unless property of @defaultPropertyValues()
    
    @save() if persist

  defaultPropertyValues: ->
    if @getShape() then @getShape().defaultPropertyValues() else {}

  setPropertyValue: (property, value, persist = true) ->
    # We could check the shape first, to see if it has a slot/property with such a name!
    @propertyValues[property] = value
    @trigger("propertyUpdate")
    @save() if persist
  
  removePropertyValue: (property, persist = true) ->
    delete @propertyValues[property]
    @trigger("propertyRemove")
    @save() if persist
  
  hasPropertyValue: (property) ->
    property of @propertyValues

  getPropertyValue: (property) ->
    @propertyValues[property]

  select: ->
    @drawing().select(@)
  
  updateSegments: (segments) =>
    @segments = new SimplifiesSegments().for(segments)
  
  reconnectTo: (node, offset) =>
    # FIXME: reference component by paper id iso firstChild
    #mover = new MovesPath(@, node, offset)
    #mover.moveStart() if node.id is @sourceId
    #mover.moveEnd() if node.id is @targetId
    #@updateSegments(mover.finalise())

    # TODO: refactor into something similar to the original MovesPath object
    @trigger('reconnect', node)

    @save()
  
  paperId: =>
    "link" + @id
      
  toPath: (renderer) =>
    group = @getShape().draw(renderer)

    path = group.firstChild
    group.name = @paperId()
    group

  select: (layer) =>
    layer.children[@paperId()].selected = true

  destroy: (options = {}) =>
    destroyed = super(options)
    memento =
      sourceId: destroyed.sourceId
      targetId: destroyed.targetId
      segments: destroyed.segments
      shape: destroyed.shape

  toSegments: =>
    for s in @segments
      new paper.Segment(s.point, s.handleIn, s.handleOut)

  linkShape: =>
    LinkShape.find(@shape) if @shape

  getShape: =>
    @linkShape()

  source: =>
    # Spine cannot circularly require Node for some reason,
    # so we require it dynamically here
    Node = require('models/node')
    Node.find(@sourceId)


  target: =>
    # Spine cannot circularly require Node for some reason
    # so we require it dynamically here
    Node = require('models/node')
    Node.find(@targetId)

    
module.exports = Link
