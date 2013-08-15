class MovesPath 
  constructor: (node, path, offset) ->
    @path = path
    @offset = offset

  finalise: =>
    @path.removeSegments(1, @path.segments.size - 2)
    @path.simplify(100)
    @path.remove()
    @path.segments

module.exports = MovesPath