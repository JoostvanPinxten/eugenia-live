Spine = require('spine')
CanvasRenderer = require('views/drawings/canvas_renderer')
class CanvasRendererManager

  constructor: ->
    @registeredCanvases = []

  getInstance: (options) -> 
    drawingId = options.drawing.id
    unless drawingId of @registeredCanvases
      @registeredCanvases[drawingId] = new CanvasRenderer(options)

    canvasRenderer = @registeredCanvases[drawingId]
    canvasRenderer.refresh(options)
    return canvasRenderer

canvasRendererManager = new CanvasRendererManager

module.exports = canvasRendererManager