Spine = require('spine')
Link = require('models/link')
NodeShape = require('models/node_shape')
# Should extend Element
class Node extends Spine.Model
  @configure "Node", "shape", "position", "propertyValues", "representation"
  @belongsTo 'drawing', 'models/drawing'
    
  constructor: (attributes) ->
    super
    @k = v for k,v of attributes
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
    
  links: =>
    Link.select (link) => (link.sourceId is @id) or (link.targetId is @id)

  incomingLinks: =>
    Link.select (link) => (link.targetId is @id)

  outgoingLinks: =>
    Link.select (link) => (link.sourceId is @id)

  moveBy: (distance) =>
    # don't rely on the parameter to be a paper.Point here?
    @position = distance.add(@position)
    link.reconnectTo(@, distance) for link in @links()
    #@trigger('update')
    @save()
    
  moveTo: (position) =>
    @moveBy(new paper.Point(position).subtract(@position))

  paperId: =>
    "node" + @id

  toPath:(renderer) =>
    path = @nodeShape().draw(renderer)
    path.name = @paperId()
    path
  
  select: (layer) ->
    layer.children[@paperId()].selected = true
    @trigger('selected')

  destroy: (options = {}) =>
    destroyed = super(options)
    memento =
      shape: destroyed.shape
      position: destroyed.position
  
  nodeShape: =>
    NodeShape.find(@shape) if @shape and NodeShape.exists(@shape)
      
  getShape: =>
    @nodeShape()

module.exports = Node