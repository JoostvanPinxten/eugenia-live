Bacon = require('baconjs/dist/Bacon')
redrawCoordinator = require('views/drawings/redraw_coordinator')

class BasicShape
  constructor: (@parent, @options) ->
    # the current representation initializes to null
    @current = null

  # node argument is redundant
  createElement : (node, renderer) ->

    # TODO: only recreate if one of the element's specification depends on a full redraw AND is based on a property
    # TODO: only update the 'style' or position in case there is a relevant change (e.g. property has changed on which a def depends)
    Bacon.fromEventTarget(node, "propertyUpdate").onValue(@create, renderer) 
    @create(renderer, node, @parent)

  # node argument is redundant
  create : (renderer, node, parent) ->
    throw  "createElement method not implemented for #{@constructor.name}"

# node argument is redundant
  updateElement: (renderer, node) ->
    # either use this method and check if the geometry should change and only then
    # create a new shape instance, or use a different method that never changes the geometry, 
    # but only the position and style of elements?
    throw  "updateElement method not implemented for #{@constructor.name}"

    
  getOption: (content, node, defaultValue) ->
    if (typeof content is 'string' or content instanceof String) and content.length and content[0] is "$"
      ExpressionEvaluator = require('models/helper/expression_evaluator')
      evaluator = new ExpressionEvaluator

      evaluator.evaluate(node, content)
    else
      content

  # removes the current representation (if any) and substitutes @arg other as the new representation
  changeElementTo: (other) ->
    if@current
      @current.remove()
    @current = other

    redrawCoordinator.requestRedraw(true)


module.exports = BasicShape