BasicShape = require('views/drawings/shapes/basic_shape')

class RoundedRectangle extends BasicShape
  constructor: (parent, options) ->
    super(parent, options)
    # overwrites the options set by super?
    @options = @setDefaultOptions(options)

  setDefaultOptions: (options) ->
    options or= {}
    options.borderRadius or= 0 # default to a normal rectangle
    
    options.strokeColor or= "black"
    options.fillColor or= "white"
    
    options.size or= {}
    options.size.width or= 100
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
    width = @getOption(@options.size.width, node, 100)
    height = @getOption(@options.size.height, node, 100)
    rect = new paper.Rectangle(0, 0, width, height)

    rounded = new paper.Path.RoundRectangle(rect, new paper.Size(@options.borderRadius, @options.borderRadius))
    rounded.position = new paper.Point(10,10)
    renderer.linkElementToModel(rounded)

    @parent.addChild(rounded)
    
    @changeElementTo(rounded)
    # reconnect links? geometry may have changed?
    @updateElement(renderer, node)

# node argument is redundant
  updateElement: (renderer, node) ->
    fillColor = @getOption(@options.fillColor, node, "transparent")
    @current.fillColor = if (fillColor is "transparent") then null else fillColor
    @current.strokeColor = @getOption(@options.borderColor, node, "black")
    @current.strokeWidth = @getOption(@options.borderWidth, node, 1) if @options.borderWidth

    x = @getOption(@options.x, node, 0)
    y = @getOption(@options.y, node, 0)
#    console.log(node, renderer)
    #console.log('updateEl', node.paperId(), node.position)
    @current.position = new paper.Point(node.position).add([x, y])


module.exports = RoundedRectangle