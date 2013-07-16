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
    @propertyValues or= @getShape().defaultPropertyValues() if @getShape()
    @propertyValues or= {}
  
  setPropertyValue: (property, value) ->
    # We could check the shape first, to see if it has a slot/property with such a name!
    @propertyValues[property] = value
    @save()
  
  getPropertyValue: (property) ->
    @propertyValues[property]
    
  links: =>
    Link.select (link) => (link.sourceId is @id) or (link.targetId is @id)

  moveBy: (distance) =>
    @position = distance.add(@position)
    link.reconnectTo(@id, distance) for link in @links()
    @save()
    @trigger("update")

  paperId: =>
    "node" + @id

  toPath:(renderer) =>
    path = @nodeShape().draw(renderer)
    path.name = @paperId()
    path
  
  select: (layer) =>
    layer.children[@paperId()].selected = true
  
  destroy: (options = {}) =>
    destroyed = super(options)
    memento =
      shape: destroyed.shape
      position: destroyed.position
  
  nodeShape: =>
    NodeShape.find(@shape) if @shape and NodeShape.exists(@shape)
      
  getShape: =>
    @nodeShape()

  update: ->
    #@drawing.refresh()
    #console.log('updateje')
    
module.exports = Node