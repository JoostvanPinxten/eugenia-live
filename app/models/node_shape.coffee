Spine = require('spine')
Shape = require('models/shape')
Label = require('models/helpers/label')
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
    # by name.
    renderer.children = (@createElement(e, renderer.item.position) for e in @elements)
    repr = new paper.Group(renderer.children)
    #renderer.representation[repr.id] = this
    renderer.representation[@paperId(renderer.item)] = repr
    #renderer.shapes[repr.id] = repr
    # now that we are certain that we have a representation, 
    # refresh it, so that it reflects the current value of its properties
    @refresh(renderer, e, repr)
    repr

  createElement: (e, position) =>
    e.x or= 0
    e.y or= 0
    path = @createPath(e.figure, e.size, e)

    path.position = new paper.Point(position).add(e.x, e.y)
    
    path.fillColor = e.fillColor unless e.fillColor is "transparent"
    path.strokeColor = e.borderColor
    path

  # TODO: document these for the user!
  # TODO: provide some user options for the location of elements
  # TODO: might refactor this into simple elements that have their 
  # own 'refresh', which can be executed in a certain context
  createPath: (figure, size, options) =>
    switch figure
      when "rounded"
        rect = new paper.Rectangle(0, 0, size.width, size.height)
        new paper.Path.RoundRectangle(rect, new paper.Size(10, 10))
      when "ellipse"
        rect = new paper.Rectangle(0, 0, size.width*2, size.height*2)
        new paper.Path.Oval(rect)
      when "rectangle"  
        new paper.Path.Rectangle(0, 0, size.width, size.height)
      when "line"
        new paper.Path.Line(new paper.Point(0, 0), new paper.Point(size.width, size.height))
      when "polygon"
        options.sides or= 3
        options.radius or= 50
        new paper.Path.RegularPolygon(new paper.Point(0, 0), options.sides, options.radius)
      when "path"
        path = new paper.Path()
        for point in options.points
          path.add(new paper.Point(point.x, point.y))
        
        path
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
  @configure "NodeShape", "name", "properties", "label", "elements"
  @belongsTo 'palette', 'models/palette'
  
  constructor: (attributes) ->
    super
    @createDelegates()
    @bind("update", @createDelegates)
    @bind("destroy", @destroyNodes)
  
  createDelegates: =>
    @_elements = new Elements(@elements)
    @_label = new Label(@label)
  
  defaultPropertyValues: =>
    defaults = {}
    defaults[property] = "" for property in @properties if @properties
    defaults
  
  displayName: =>
    @name.charAt(0).toUpperCase() + @name.slice(1)
  
  draw: (renderer) =>
    group = new paper.Group

    shape = @_elements.draw(renderer)
    group.addChild(shape)
    label = @_label.draw(renderer, group, shape)
    group.addChild(label)
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