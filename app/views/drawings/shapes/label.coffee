redrawCoordinator = require('views/drawings/redraw_coordinator')

class Label
  constructor: (@definition) ->
    if @definition and @definition.placement isnt "none"
      @definition.for = [@definition.for] unless @definition.for instanceof Array
      @definition.pattern = @default_pattern() unless @definition.pattern
    else
      @definition = { placement: "none" }

    @definition.color or="black"

  default_pattern: ->
    numbers = [0..@definition.for.length-1]
    formattedNumbers = ("{#{n}}" for n in numbers)
    formattedNumbers.join(",")
  
  paperId: (parent) ->
    parent.paperId() + "-label"

  draw: (renderer, group, shape) ->
    labelName = @paperId(renderer.item)
    #console.log(shape)
    textItem = group.children[labelName]
    
    unless textItem
      #result = new paper.Group(shape)
      position = @positionFor(shape)
      textItem = @createText(renderer.item, position)
      textItem.name = labelName
      @updateText(textItem, renderer.item, shape)
      #result.addChild(textItem)
      renderer.representation[this] = textItem
    textItem
    
  
  positionFor: (shape) ->
    if @definition.placement is "external"
      offset = @definition.offset or [0,20]
      shape.bounds.bottomCenter.add(offset) # nudge outside shape
    else
      offset = @definition.offset or [0,0]
      shape.position.add(offset) # nudge down to middle of shape

  updateText: (textItem, node, shape) ->
    if textItem
      if @definition.placement is "none"
        textItem.content = ""
      else
        textItem.content = @contentFor(node)
    textItem.position = @positionFor(shape)
    redrawCoordinator.requestRedraw(true)


  createText: (node, position) ->
    text = new paper.PointText(position)
    text.justification = 'center'
    text.fillColor = @definition.color
    text
  
  contentFor: (node) ->
    # TODO: can't this be done by name? e.g. a key-value binding?
    # and map it to the EuGENia definition when it's applicable?
    content = @definition.pattern    
    for number in [0..@definition.for.length-1]
      pattern = ///
        \{
        #{number}
        \}
      ///g
      value = node.getPropertyValue(@definition.for[number])
      content = content.replace(pattern, value)
    
    @trimText(content)
  
  trimText: (text) ->
    return "" unless text
    return text unless text.length > @definition.length
    return text.substring(0, @definition.length-3).trim() + "..."
      

module.exports = Label