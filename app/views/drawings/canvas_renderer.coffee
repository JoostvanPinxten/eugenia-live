Link = require('models/link')
Node = require('models/node')
Bacon = require('baconjs/dist/Bacon')
redrawCoordinator = require('views/drawings/redraw_coordinator')

class CanvasRenderer
  constructor: (options) ->
    @canvas = options.canvas
    @drawing = options.drawing
    
    paper.setup(@canvas)
    @bindToChangeEvents()
    @addAll(Node)
    @addAll(Link)
    redrawCoordinator.bind "rendered", @saveDrawingCache

    ###
    @grid = new paper.Group

    for i in [0..50]
      l = new paper.Path.Line( new paper.Point(i*20,0), new paper.Point(i*20, 400) )
      l.strokeColor = 'gray';
      @grid.addChild l
    for j in [0..20]
      l = new paper.Path.Line( new paper.Point(0,j*20), new paper.Point(1000, j*20) )
      l.strokeColor = 'gray';

      @grid.addChild l
      
    console.log 'added grid'
    paper.project.activeLayer.insertChild(0, @grid)
    ###
  bindToChangeEvents: =>

    # This is necessary to remove bindings that were already in place (by e.g. switching from editing to simulating)
    Node.unbind("create")
    Link.unbind("create")
    Node.unbind("refresh")
    Link.unbind("refresh")

    Node.bind("refresh", => @addAll(Node))
    Link.bind("refresh", => @addAll(Link))
    Node.bind("create", @addOne)
    Link.bind "create", @addOne
    
  addAll: (type) =>
    associationMethod = type.className.toLowerCase() + 's' #e.g. Node -> nodes
    elements = @drawing[associationMethod]().all()         #e.g. @drawing.nodes().all()
    #console.log("adding all " + elements.length + " " + type.className + "s")
    @addOne(element) for element in elements
    @drawingCacheInvalid = true
  
  addOne: (element) =>
    # Set-up a renderer, then trigger 'updates' and 'destroys' on the item
    renderer = require("views/drawings/#{element.constructor.className.toLowerCase()}_renderer")
    
    if (renderer)
      new renderer(element)
    else
      console.warn("no renderer attached for " + element)
    @renderOne(element)
    #element.bind("propertyUpdate", (el) -> console.log("prop update"))
    #element.bind("propertyUpdate", (el) -> element.trigger("render"))
    #stream = Bacon.fromEventTarget(element, "update")
    #stream.onValue (element) -> console.log(element.getPropertyValue("name"))
    @drawingCacheInvalid =true
  
  renderOne: (element) =>
    element.trigger("render")
    ###unless 
    renderer = require("views/drawings/#{element.constructor.className.toLowerCase()}_renderer")
    
    if (renderer)
      new renderer(element).render()
    else
      console.warn("no renderer attached for " + element)
      ###
  
  saveDrawingCache: =>
    if @drawingCacheInvalid
      @drawing.cache = @canvas.toDataURL()
      @drawing.save()
      @drawingCacheInvalid = false
    
module.exports = CanvasRenderer