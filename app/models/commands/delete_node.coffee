DeleteLink = require('models/commands/delete_link')

class DeleteNode
  constructor: (@drawing, @node) ->
  
  run: =>  
    @runDeleteLinks()
    @nodeMemento = @node.destroy()
    paper.view.draw(true)
  
  undo: =>
    oldId = @node.id
    @node = @drawing.addNode(@nodeMemento)
    @undoDeleteLinks(oldId, @node.id)
    paper.view.draw(true)

  
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