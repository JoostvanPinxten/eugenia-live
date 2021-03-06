require = window.require

describe 'MovesPath', ->
  MovesPath = require('models/moves_path')

  beforeEach ->
    paper.setup($('canvas')[0])

    @start  = new paper.Point(10, 20)
    @middle = new paper.Point(20, 30)
    @end    = new paper.Point(30, 40)

    @path = new paper.Path()
    @path.add(@start)
    @path.add(@middle)
    @path.add(@end)
    
    @offset = new paper.Point(50, 100)
    @mover = new MovesPath(@path, @offset)

    @addMatchers(
      toBeInTheSamePlaceAs: (expected) ->
        @message = -> "Expected (#{expected.x},#{expected.y}) but got (#{@actual.x},#{@actual.y})"
        
        (@actual.x is expected.x) and (@actual.y is expected.y)
    )
###
  it 'can move the start of a path', ->
    @mover.moveStart()
    expect(@path.firstChild.firstSegment.point).toBeInTheSamePlaceAs(@start.add(@offset))
    
  it 'can move the end of a path', ->
    @mover.moveEnd()
    expect(@path.firstChild.lastSegment.point).toBeInTheSamePlaceAs(@end.add(@offset))
    
  it 'can move the start and end of a path without affecting the middle', ->
    @mover.moveStart()
    @mover.moveEnd()
    expect(@path.firstChild.segments[1].point).toBeInTheSamePlaceAs(@middle)
    
  it 'can remove the middle when finalising', ->
    expect(@mover.finalise().length).toEqual(2)
    ###