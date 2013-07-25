Spine = require('spine')
Link = require('models/link')
NodeShape = require('models/node_shape')
simulationPoll = require('controllers/simulation_poll')

# Should extend Element
class Node extends Spine.Model
  @configure "Node", "shape", "position", "propertyValues", "representation"
  @belongsTo 'drawing', 'models/drawing'
    
  constructor: (attributes) ->
    super
    @k = v for k,v of attributes
    @initialisePropertyValues()

    @getShape().bind "update", => console.log("updating instance")
    #simulationPoll.currentTime.onValue (tick) =>
      #@simulate(tick)


  initialisePropertyValues: ->
    @propertyValues or= @getShape().defaultPropertyValues() if @getShape()
    @propertyValues or= {}
  
  setPropertyValue: (property, value) ->
    # We could check the shape first, to see if it has a slot/property with such a name!
    @propertyValues[property] = value
    @trigger("propertyUpdate")
    @save()
  
  getPropertyValue: (property) ->
    @propertyValues[property]
    
  links: =>
    Link.select (link) => (link.sourceId is @id) or (link.targetId is @id)

  moveBy: (distance) =>
    @position = distance.add(@position)
    link.reconnectTo(@, distance) for link in @links()
    @save()
    
  moveTo: (position) =>
    @moveBy(new paper.Point(position).subtract(@position))

  paperId: =>
    "node" + @id

  toPath:(renderer) =>
    path = @nodeShape().draw(renderer)
    path.name = @paperId()
    path
  
  select: (layer) =>

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

  simulate: (currentTime) =>
    if @getShape().behavior and @getShape().behavior.tick
      for property, expression of @getShape().behavior.tick
        @setPropertyValue(property, eval(expression))
        #console.log(property, expression)
    
module.exports = Node