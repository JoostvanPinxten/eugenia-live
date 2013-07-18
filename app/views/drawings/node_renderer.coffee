ElementRenderer = require('views/drawings/element_renderer')

# FIXME: are these properly cleaned up? Could be the case that there is still some reference floating around somewhere?
class NodeRenderer extends ElementRenderer

  constructor: (@item) ->
    super(@item)
    
    @el = null

  draw: =>
    unless @el 
      @el = @item.toPath(@)
    @item.nodeShape().refresh(@)
      
module.exports = NodeRenderer