Spine = require('spine')
Label = require('models/helpers/label')

Bacon = require('baconjs/dist/Bacon').Bacon
redrawCoordinator = require('views/drawings/redraw_coordinator')

class BasicShape
  constructor: (@parent, @options) ->
    # the current representation initializes to null
    @current = null


  # node argument is redundant
  createElement : (node, renderer) ->
    throw  "createElement method not implemented for #{@constructor.name}"

# node argument is redundant
  updateElement: (node, renderer) ->
    # either use this method and check if the geometry should change and only then
    # create a new shape instance, or use a different method that never changes the geometry, 
    # but only the position and style of elements?
    throw  "updateElement method not implemented for #{@constructor.name}"

class RoundedRectangle extends BasicShape
  constructor: (@parent, options) ->
    super(options)
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
    
  getOption: (content, node, defaultValue) ->
    if (typeof content is 'string' or content instanceof String) and content.length and content[0] is "$"
      
      # What happens if there is a problem with the expression
      # for example ${unknown} where unknown is not a property
      # that is defined for this shape
      
      # strip off opening the ${ and the closing }
      evalable = content.substring(2, content.length - 1)
      content = node.getPropertyValue(evalable)
    
      # What happens if this fails?
      if content is ""
        defaultValue
      else
        # Eventually, we probably want to store type information
        # for parameter values so that we can perform a more
        # knowledgable conversion, rather than trial-and-error
        value = parseInt(content,10)
        value = content if isNaN(value)
        value
    else
      content
  
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
    fillColor = @getOption(@options.fillColor, node, "transparent")
    rounded.fillColor = if (fillColor is "transparent") then null else fillColor
    rounded.strokeColor = @getOption(@options.borderColor, node, "black")

    renderer.linkElementToModel(rounded)

    x = @getOption(@options.x, node, 0)
    y = @getOption(@options.y, node, 0)
    point = new paper.Point(node.position).add([x, y])
    
    @parent.addChild(rounded)

    rounded.position = point

    if@current
      @current.remove()
    @current = rounded
    # reconnect links? geometry may have changed?
    redrawCoordinator.requestRedraw(true)

  # node argument is redundant
  createElement : (node, renderer) ->

        Bacon.fromEventTarget(node, "propertyUpdate").onValue(@create, renderer) 
        @create(renderer, node, @parent)

# node argument is redundant
  updateElement: (node, renderer) ->
    

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
    path.position = new paper.Point(position).add(e.x, e.y) 
    path.fillColor = if (e.fillColor is "transparent") then null else e.fillColor 
    path.strokeColor = e.borderColor
    path.model = node
    path

  # TODO: document these for the user!
  # TODO: provide some user options for the location of elements
  # TODO: might refactor this into simple elements that have their 
  # own 'refresh', which can be executed in a certain context
  createPath: (group, figure, size, options, node, renderer) =>

    # something like: update function that sets the variables according to the 
    # expressions set in the definition, listening to the update events of node, 
    # based on the values of the properties

    # e.g. width : "${width}" <- look up propertyValue for property called "width" on node?

    # check if it is a string or a number first
    # string -> always parse it as an expression and then throw an "eval" over it
    # number -> apply directly

    # delegate the information to the proper subtype
    switch figure
      when "rounded"
        options.borderRadius or= 10 # default to 10 pixels border radius, in case none has been set
        shape = new RoundedRectangle(group, options)
        path = shape.createElement(node, renderer)

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
  @configure "NodeShape", "name", "properties", "label", "elements", "behavior"
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