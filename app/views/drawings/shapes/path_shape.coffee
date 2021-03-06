BasicShape = require('views/drawings/shapes/basic_shape')

class PathShape extends BasicShape
  constructor: (parent, options) ->
    super(parent, options)
    # overwrites the options set by super?
    @options = @setDefaultOptions(options)

  setDefaultOptions: (options) ->
    options or= {}
    
    options.strokeColor or= "black"
    options.fillColor or= "white"
    
    options.size or= {}
    options.size.width or= 50
    options.size.height or= 100
    
    options.x or= 0
    options.y or= 0

    options
  
    ###
      The create method  looks for properties that it can use to set the 
      geometry of the shapes. It then matches text surrounded by ${ and } 
      and then evaluates the contents as the current/previous? value of these properties.           

      FIXME: provide a parser to do this properly
      FIXME: in what order should the contents be evaluated? it is currently evaluated 
      in the order of appearance of the properties in its shape
    ###
  create: (renderer, node, parent) =>
    width = @getOption(@options.size.width, node, 50)
    height = @getOption(@options.size.height, node, 100)

    path = new paper.Path()
    for point in @options.points
      path.add(new paper.Point(@getOption(point.x), @getOption(point.y)))

    # factor out to something like: apply style?
    fillColor = @getOption(@options.fillColor, node, "transparent")
    path.fillColor = if (fillColor is "transparent") then null else fillColor
    path.strokeWidth = @getOption(@options.borderWidth, node, 1) if @options.borderWidth
    path.strokeColor = @getOption(@options.borderColor, node, "black")

    renderer.linkElementToModel(path)

    @parent.addChild(path)
    @changeElementTo(path)
    @updateElement(renderer, node)

    # reconnect links? geometry may have changed?

# node argument is redundant
  updateElement: (renderer, node) ->
    fillColor = @getOption(@options.fillColor, node, "transparent")
    @current.fillColor = if (fillColor is "transparent") then null else fillColor
    @current.strokeColor = @getOption(@options.borderColor, node, "black")

    x = @getOption(@options.x, node, 0)
    y = @getOption(@options.y, node, 0)
    @current.position = new paper.Point(node.position).add([x, y])
    
module.exports = PathShape