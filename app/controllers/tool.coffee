Node = require('models/node')
Link = require('models/link')
DeleteElement = require('models/commands/delete_element')

class Tool
  
  constructor: (options) ->
    @commander = options.commander
    @hitTester = options.hitTester
    @hitTester or= new PaperHitTester
    @drawing = options.drawing
    
    @_tool = new paper.Tool
    @_tool.onMouseMove = @onMouseMove
    @_tool.onMouseDrag = @onMouseDrag
    @_tool.onMouseDown = @onMouseDown
    @_tool.onMouseUp = @onMouseUp
    @_tool.onKeyDown = @onKeyDown
    @_tool.onKeyUp = @onKeyUp
  
  activate: =>
    @_tool.activate()
  
  setParameter: (parameterKey, parameterValue) ->
    @parameters or= {}
    @parameters[parameterKey] = parameterValue
  
  run: (command, options={undoable: true}) ->
    @commander.run(command, options)

  onKeyDown: (event) =>
    # don't intercept key events if any DOM element
    # (e.g. form field) has focus
    # FIXME: don't intercept values in case the canvas is in simulation mode (e.g. data-simulation=true?)
    if (document.activeElement is document.body)      
      if (event.key is 'delete')
        @run(new DeleteElement(@drawing, e)) for e in @selection()
        @clearSelection()
      else if (event.key is 'z' and event.event.ctrlKey) # CTRL + Z has been pressed
        @commander.undo()

  changeSelectionTo: (nodeOrLink) ->
    @clearSelection()
    @select(nodeOrLink)

  clearSelection: ->
    @drawing.clearSelection()
  
  select: (nodeOrLink) ->
    @drawing.select(nodeOrLink)
  
  selection: ->
    @drawing.selection


class PaperHitTester
  nodeOrLinkAt: (point) ->
    result = @nodeAt(point)
    result = @linkAt(point) unless result
    result
  
  linkAt: (point) ->
    @xAt(point, Link)
  
  nodeAt: (point) ->
    @xAt(point, Node)

  xAt: (point, type) ->
    hitResult = paper.project.hitTest(point)
    hitResult.item.model if hitResult and (hitResult.item.model instanceof type)
    
module.exports = Tool