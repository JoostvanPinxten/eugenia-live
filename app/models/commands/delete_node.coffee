DeleteLink = require('models/commands/delete_link')
redrawCoordinator = require('views/drawings/redraw_coordinator')

class DeleteNode
  constructor: (@drawing, @node) ->
  
  run: =>  
    @runDeleteLinks()
    @nodeMemento = @node.destroy()
    redrawCoordinator.requestRedraw(true)
  
  undo: =>
    oldId = @node.id
    @node = @drawing.addNode(@nodeMemento)
    @undoDeleteLinks(oldId, @node.id)
    redrawCoordinator.requestRedraw(true)

  
  runDeleteLinks: =>
    @linkCommands = []
    for link in @node.links()
      lc = new DeleteLink(@drawing, link)
      lc.run()
      @linkCommands.push(lc)
    
  undoDeleteLinks: (oldId, newId) =>
    for lc in @linkCommands
      lc.rebase(oldId, newId)
      lc.undo()
    
    
module.exports = DeleteNode