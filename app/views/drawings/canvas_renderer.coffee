Link = require('models/link')
Node = require('models/node')

class CanvasRenderer
  constructor: (options) ->
    @canvas = options.canvas
    @drawing = options.drawing
    
    paper.setup(@canvas)
    @bindToChangeEvents()
    @addAll(Node)
    @addAll(Link)
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
    @updateDrawingCache()
  
  addOne: (element) =>
    # Set-up a renderer, then trigger 'updates' and 'destroys' on the item
    renderer = require("views/drawings/#{element.constructor.className.toLowerCase()}_renderer")
    
    if (renderer)
      new renderer(element)
    else
      console.warn("no renderer attached for " + element)
    @renderOne(element)
    @updateDrawingCache()
  
  renderOne: (element) =>
    element.trigger("update")
    ###unless 
    renderer = require("views/drawings/#{element.constructor.className.toLowerCase()}_renderer")
    
    if (renderer)
      new renderer(element).render()
    else
      console.warn("no renderer attached for " + element)
      ###
  
  updateDrawingCache: =>
    @drawing.cache = @canvas.toDataURL()
    @drawing.save()
    
module.exports = CanvasRenderer