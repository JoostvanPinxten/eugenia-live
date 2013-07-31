BasicShape = require('views/drawings/shapes/basic_shape')

class LineShape extends BasicShape
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

    line = new paper.Path.Line(new paper.Point(0, 0), new paper.Point(@getOption(@options.size.width, @options.size.height)))

    # factor out to something like: apply style?
    fillColor = @getOption(@options.fillColor, node, "transparent")
    line.fillColor = if (fillColor is "transparent") then null else fillColor
    line.strokeColor = @getOption(@options.borderColor, node, "black")

    renderer.linkElementToModel(line)

    # perhaps move all this to changeElementTo? Seems to be generic for all shapes
    x = @getOption(@options.x, node, 0)
    y = @getOption(@options.y, node, 0)
    point = new paper.Point(node.position).add([x, y])
    
    @parent.addChild(line)
    line.position = point
    @changeElementTo(line)
    # reconnect links? geometry may have changed?

  updateElement: (node, renderer) ->
    fillColor = @getOption(@options.fillColor, node, "transparent")
    @current.strokeColor = @getOption(@options.strokeColor, node, "black")

module.exports = LineShape