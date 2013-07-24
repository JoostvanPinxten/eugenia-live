class DeleteLink
  constructor: (@drawing, @link) ->
  
  run: =>  
    @memento = @link.destroy()
    paper.view.draw(true)
  
  undo: =>
    @drawing.addLink(@memento)
    paper.view.draw(true)
    
  rebase: (oldId, newId) =>
    @memento.sourceId = newId if @memento.sourceId is oldId
    @memento.targetId = newId if @memento.targetId is oldId
    
module.exports = DeleteLink