class DeleteLink
  constructor: (@drawing, @link) ->
  
  run: =>  
    @memento = @link.destroy()
    paper.view.draw()
  
  undo: =>
    @drawing.addLink(@memento)
    paper.view.draw()
    
  rebase: (oldId, newId) =>
    @memento.sourceId = newId if @memento.sourceId is oldId
    @memento.targetId = newId if @memento.targetId is oldId
    
module.exports = DeleteLink