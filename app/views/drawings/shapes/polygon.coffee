BasicShape = require('views/drawings/shapes/basic_shape')

class PolygonShape extends BasicShape
  constructor: (parent, options) ->
    super(parent, options)
    # overwrites the options set by super?
    @options = @setDefaultOptions(options)

  setDefaultOptions: (options) ->
    options or= {}
    
    options.borderColor or= "black"
    options.fillColor or= "white"
    
    options.sides or= 5
    options.radius or= 50
    
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

    polygon = new paper.Path.RegularPolygon(new paper.Point(0, 0), @getOption(@options.sides), @getOption(@options.radius))

    # factor out to something like: apply style?
    fillColor = @getOption(@options.fillColor, node, "transparent")
    polygon.fillColor = if (fillColor is "transparent") then null else fillColor
    polygon.strokeColor = @getOption(@options.borderColor, node, "black")
    path.strokeWidth = @getOption(@options.borderWidth, node, 1) if @options.borderWidth

    renderer.linkElementToModel(polygon)

    
    @parent.addChild(polygon)
    @changeElementTo(polygon)
    # reconnect links? geometry may have changed?
    @updateElement(renderer, node)

  
  updateElement: (renderer, node) ->
    x = @getOption(@options.x, node, 0)
    y = @getOption(@options.y, node, 0)
    point = new paper.Point(node.position).add([x, y])
    @current.position = point

    fillColor = @getOption(@options.fillColor, node, "transparent")
    @current.fillColor = if (fillColor is "transparent") then null else fillColor
    @current.strokeColor = @getOption(@options.borderColor, node, "black")
module.exports = PolygonShape
