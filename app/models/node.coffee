Spine = require('spine')
Link = require('models/link')
NodeShape = require('models/node_shape')

class Node extends Spine.Model
  @configure "Node", "shape", "position", "propertyValues"
  @belongsTo 'drawing', 'models/drawing'
  @extend Spine.Model.Local
    
  constructor: (attributes) ->
    super
    @propertyValues or= {}
    @k = v for k,v of attributes
    @bind("destroy", @destroyLinks)
  
  setPropertyValue: (property, value) ->
    @propertyValues[property] = value
  
  getPropertyValue: (property) ->
    @propertyValues[property]
  
  destroyLinks: =>
    link.destroy() for link in @links()
    
  links: =>
    Link.select (link) => (link.sourceId is @id) or (link.targetId is @id)

  moveTo: (destination) =>
    link.reconnectTo(@id, destination.subtract(@position)) for link in @links()
    @position = destination

  toPath: =>
    s = NodeShape.find(@shape)
    path = s.draw(@)
    path


module.exports = Node