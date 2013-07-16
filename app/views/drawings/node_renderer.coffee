ElementRenderer = require('views/drawings/element_renderer')

class NodeRenderer extends ElementRenderer

  constructor: (@item) ->
    super(item)
    @el = null

  draw: =>
    @el = @item.toPath(@) unless @el 
    @item.nodeShape().refresh(@)
      
module.exports = NodeRenderer