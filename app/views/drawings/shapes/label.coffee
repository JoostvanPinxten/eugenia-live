redrawCoordinator = require('views/drawings/redraw_coordinator')


class Label
  constructor: (@definition) ->
    if @definition and @definition.placement isnt "none"
      @definition.pattern = @definition.pattern
    else
      @definition = { placement: "none" }

    @definition.color or="black"
    ExpressionEvaluator = require('models/helper/expression_evaluator')
    @evaluator = new ExpressionEvaluator

  paperId: (parent) ->
    parent.paperId() + "-label"

  draw: (renderer, group, shape) ->
    labelName = @paperId(renderer.item)
    textItem = group.children[labelName]
    
    unless textItem
      position = @positionFor(shape)
      textItem = @createText(renderer.item, position)
      textItem.name = labelName
      @updateText(textItem, renderer.item, shape)
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
    content = @evaluator.evaluate(node, content) if content
    @trimText(content)
  
  trimText: (text) ->
    return "" unless text
    return text unless text.length > @definition.length
    return text.substring(0, @definition.length-3).trim() + "..."
      

module.exports = Label