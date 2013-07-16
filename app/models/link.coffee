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
  
  reconnectTo: (nodeId, offset) =>
    mover = new MovesPath(@toPath().firstChild, offset)
    mover.moveStart() if nodeId is @sourceId
    mover.moveEnd() if nodeId is @targetId
    @updateSegments(mover.finalise())
    @save()
  
  paperId: =>
    "link" + @id
      
  toPath: =>
    s = LinkShape.find(@shape)
    group = s.draw(@)

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
