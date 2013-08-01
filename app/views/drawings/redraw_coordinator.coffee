Bacon = require('baconjs/dist/Bacon')
Spine = require('spine')

class RedrawCoordinator extends Spine.Model
  # should actually extend Spine.Module and Spine.Events, but that
  # does not provide me with the right methods.
  #@extend(Spine.Events)

  constructor: ->
    super
    @needsRedraw = false

    Bacon.fromPoll(20).onValue =>
      @onFrame()

  requestRedraw: ->
    @needsRedraw = true

  onFrame: =>

    if @needsRedraw
      if(paper['view'])
        paper.view.draw()
        #console.log(@)
        @trigger("rendered")

    @needsRedraw = false

redrawCoordinator = new RedrawCoordinator

redrawCoordinator.requestRedraw()

module.exports = redrawCoordinator