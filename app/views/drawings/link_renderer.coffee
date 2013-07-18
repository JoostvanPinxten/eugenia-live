ElementRenderer = require('views/drawings/element_renderer')

# FIXME: are these properly cleaned up? Could be the case that there is still some reference floating around somewhere?
class LinkRenderer extends ElementRenderer

  constructor: (@item) ->
    super(@item)

    @el = null
    @item.bind("reconnect", @reconnect)

  draw: =>
    @el = @item.toPath(@) unless @el
    
    # FIXME trim the line in the tool
    # rather than hiding the overlap behind the nodes here

    # TODO the above FIXME will also enable us to create symbols for start/end points
    @refresh()

  refresh: =>
    @item.linkShape().refresh(@)
    @sendToBack()
    
  reconnect: (link, node) =>
    newPos = node.position
    # TODO: fix paper references (on id iso first/lastChild)
    path = @representation[link.getShape()]

    if node.id is link.sourceId
      path.firstSegment.point.x = newPos.x 
      path.firstSegment.point.y = newPos.y
    if node.id is link.targetId
      path.lastSegment.point.x = newPos.x
      path.lastSegment.point.y = newPos.y

    link.updateSegments(path.segments)
    @refresh()
module.exports = LinkRenderer