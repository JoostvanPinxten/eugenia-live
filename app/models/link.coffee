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
    @propertyValues or= @getShape().defaultPropertyValues() if @getShape()
    @propertyValues or= {}
  
  setPropertyValue: (property, value) ->
    # We could check the shape first, to see if it has a slot with such a name!
    @propertyValues[property] = value
    @save()
  
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
    s = LinkShape.find(@shape)
    group = s.draw(renderer)

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

    
module.exports = Link
