BasicShape = require('views/drawings/shapes/basic_shape')

class PolygonShape extends BasicShape
  constructor: (parent, options) ->
    super(parent, options)
    # overwrites the options set by super?
    @options = @setDefaultOptions(options)

  setDefaultOptions: (options) ->
    options or= {}
    
    options.strokeColor or= "black"
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

    renderer.linkElementToModel(polygon)

    # perhaps move all this to changeElementTo? Seems to be generic for all shapes
    x = @getOption(@options.x, node, 0)
    y = @getOption(@options.y, node, 0)
    point = new paper.Point(node.position).add([x, y])
    
    @parent.addChild(polygon)
    polygon.position = point
    @changeElementTo(polygon)
    # reconnect links? geometry may have changed?
  
  updateElement: (node, renderer) ->
    fillColor = @getOption(@options.fillColor, node, "transparent")
    @current.fillColor = if (fillColor is "transparent") then null else fillColor
    @current.strokeColor = @getOption(@options.borderColor, node, "black")
module.exports = PolygonShape
