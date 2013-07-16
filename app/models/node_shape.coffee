Spine = require('spine')
Shape = require('models/shape')
Label = require('models/helpers/label')
class Elements
  constructor: (elements) ->
    @elements = elements
    
  draw: (node) ->
    children = (@createElement(e, node.position) for e in @elements)
    new paper.Group(children)

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
  
  draw: (node) =>
    @_label.draw(node, @_elements.draw(node))
      
  destroyNodes: ->
    node.destroy() for node in require('models/node').findAllByAttribute("shape", @id)
    
module.exports = NodeShape