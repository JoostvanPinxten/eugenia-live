redrawCoordinator = require('views/drawings/redraw_coordinator')

class DeleteLink
  constructor: (@drawing, @link) ->
  
  run: =>  
    @memento = @link.destroy()
    redrawCoordinator.requestRedraw(true)
  
  undo: =>
    @drawing.addLink(@memento)
    redrawCoordinator.requestRedraw(true)
    
  rebase: (oldId, newId) =>
    @memento.sourceId = newId if @memento.sourceId is oldId
    @memento.targetId = newId if @memento.targetId is oldId
    
module.exports = DeleteLink