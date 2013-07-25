Bacon = require('baconjs/dist/Bacon')

class RedrawCoordinator
  constructor: ->
    @needsRedraw = false

    Bacon.fromPoll(20).onValue =>
      @onFrame()

  requestRedraw: ->
    @needsRedraw = true

  onFrame: ->

    if @needsRedraw
      if(paper['view'])
        paper.view.draw()

    @needsRedraw = false

redrawCoordinator = new RedrawCoordinator

redrawCoordinator.requestRedraw()

module.exports = redrawCoordinator