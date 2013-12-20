Link = require('models/link')
Node = require('models/node')
Bacon = require('baconjs/dist/Bacon')
redrawCoordinator = require('views/drawings/redraw_coordinator')

class CanvasRenderer
  constructor: (options) ->
    @renderers = []
    @refresh(options)

    redrawCoordinator.bind "rendered", @saveDrawingCache

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
  
  refresh: (options) ->
    @canvas = options.canvas
    @drawing = options.drawing
    paper.setup(@canvas)

    @addAll(Node)
    @addAll(Link)

    @bindToChangeEvents()


  addAll: (type) =>
    associationMethod = type.className.toLowerCase() + 's' #e.g. Node -> nodes
    elements = @drawing[associationMethod]().all()         #e.g. @drawing.nodes().all()
    #console.log("adding all " + elements.length + " " + type.className + "s")
    @addOne(element) for element in elements
    @drawingCacheInvalid = true
  
  addOne: (element) =>
    # Set-up a renderer, then trigger 'updates' and 'destroys' on the item
    elementType = element.constructor.className.toLowerCase()
    Renderer = require("views/drawings/#{elementType}_renderer")
    
    rendererId = "#{elementType};#{element.id}"
    if (Renderer)
      # reuse the renderer, in case it was already defined
      if rendererId of @renderers
        renderer = @renderers[rendererId]
        renderer.unbindAll()
      renderer = new Renderer(element)
      @renderers[rendererId] = renderer

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