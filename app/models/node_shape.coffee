Spine = require('spine')
Label = require('views/drawings/shapes/label')

Bacon = require('baconjs/dist/Bacon').Bacon
redrawCoordinator = require('views/drawings/redraw_coordinator')

Ellipse = require('views/drawings/shapes/ellipse')
RoundedRectangle = require('views/drawings/shapes/rounded_rectangle')
LineShape = require('views/drawings/shapes/line_shape')
PathShape = require('views/drawings/shapes/path_shape')
PolygonShape = require('views/drawings/shapes/polygon')

class Elements
  constructor: (elements) ->
    @elements = elements
    @children = {}
    
    #FIXME: on an update of the shape (through e.g. updateAttributes), the old renderer/nodes may still be in memory

  paperId: (item) ->
    item.paperId + '-elements'

  draw: (renderer) ->
    # We should check if this element's group already contains 
    # the paths we need to draw, which should be identifiable 
    # by name?
    group = new paper.Group()
    renderer.children = (@createElement(group, e, renderer.item.position, renderer.item, renderer) for e in @elements)

    #renderer.representation[repr.id] = this
    renderer.representation[@paperId(renderer.item)] = group
    #renderer.shapes[repr.id] = repr
    # now that we are certain that we have a representation, 
    # refresh it, so that it reflects the current value of its properties
    @refresh(renderer, e, group)
    group

  createElement: (group, e, position, node, renderer) =>
    e.x or= 0
    e.y or= 0

    path = @createPath(group, e.figure, e.size, e, node, renderer)
    # make these values dynamic in case of expression 
    #path.position = new paper.Point(position).add(e.x, e.y) 
    #path.fillColor = if (e.fillColor is "transparent") then null else e.fillColor 
    #path.strokeColor = e.borderColor
    #path.model = node
    path

  createPath: (group, figure, size, options, node, renderer) =>
    # delegate the information to the proper subtype
    switch figure
      when "rounded"
        options.borderRadius or= 10 # default to 10 pixels border radius, in case none has been set
        shape = new RoundedRectangle(group, options)
        shape.createElement(node, renderer)
      when "ellipse"
        ###rect = new paper.Rectangle(0, 0, size.width*2, size.height*2)
        new paper.Path.Oval(rect)###
        shape = new Ellipse(group, options)
        shape.createElement(node, renderer)
      when "rectangle"  
        options.borderRadius or= 0 # normal rectangle requested; this is a rounded rectangle with radius 0
        shape = new RoundedRectangle(group, options)
        shape.createElement(node, renderer)
      when "line"
        shape = new LineShape(group, options)
        shape.createElement(node, renderer)
      when "polygon"
        shape = new PolygonShape(group, options)
        shape.createElement(node, renderer)
      when "path"
        shape = new PathShape(group, options)
        shape.createElement(node, renderer)
      else
        console.warn('Unable to draw shape for ' + figure)
        paper.Path.Rectangle(0, 0, 50, 50)
  
  refresh: (renderer, element, representation) ->
    # this function may become a lot more complex? perhaps even use Bacon to do this in a nicer way
    representation.position = renderer.item.position # + the elements position?

    #representation.fillColor = if element.fillColor is "transparent" then null else element.fillColor
    #representation.strokeColor = if element.borderColor is "transparent" then null else element.borderColor

    #@updateElement(node, child, node.position) for child in @children

    #console.log(renderer.item, representation)
  updateElement: (node, path, position) ->
    #path.position = new paper.Point(position).add(e.x, e.y)
    
    #path.fillColor = e.fillColor unless e.fillColor is "transparent"
    #path.strokeColor = e.borderColor


class NodeShape extends Spine.Model
  @configure "NodeShape", "name", "properties", "label", "elements", "behavior"
  @belongsTo 'palette', 'models/palette'
  
  constructor: (attributes) ->
    super
    @properties or= []
    @createDelegates()
    @bind("update", @createDelegates)
    @bind("destroy", @destroyNodes)
  
  createDelegates: =>
    @_elements = new Elements(@elements)
    @_label = new Label(@label)
  
  defaultPropertyValues: =>
    defaults = {}
    defaults[property] = "" for property in @properties
    defaults
  
  displayName: =>
    @name.charAt(0).toUpperCase() + @name.slice(1)
  
  draw: (renderer) =>
    group = new paper.Group

    shape = @_elements.draw(renderer)
    group.addChild(shape)
    label = @_label.draw(renderer, group, shape)
    group.addChild(label)
    renderer.item.bind "propertyUpdate", (node)=>
      @_label.updateText(renderer.representation[@_label], renderer.item, shape) 
    group
      
  destroyNodes: ->
    node.destroy() for node in require('models/node').findAllByAttribute("shape", @id)
    
  refresh: (renderer) ->
    # console.log "refresh", renderer
    # can now be done based on the names of the paperId?!
    shape = renderer.representation[@_elements.paperId(renderer.item)]
    @_elements.refresh(renderer, @_elements, shape)
    @_label.updateText(renderer.representation[@_label], renderer.item, shape) 


module.exports = NodeShape