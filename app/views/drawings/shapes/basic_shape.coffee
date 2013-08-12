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
      # What happens if there is a problem with the expression
      # for example ${unknown} where unknown is not a property
      # that is defined for this shape
      
      # strip off opening the ${ and the closing }

      pattern = ///
        \$\{
        ([\w]+)
        \}
      ///g
      #props = node.getAllProperties(false) # this will always trigger a save()

      evalable = content.replace(pattern, (match, propertyName) ->
        result = match
        result = "node.getPropertyValue(\'#{propertyName}\', false)" #if propertyName in Object.keys(props)
        result
      )
      ###content = node.getPropertyValue(evalable)
    
      # What happens if this fails?
      if content is ""
        defaultValue
      else
        # Eventually, we probably want to store type information
        # for parameter values so that we can perform a more
        # knowledgable conversion, rather than trial-and-error
        value = parseInt(content,10)
        value = content if isNaN(value)
        value
    else
      content    ###
      try
        val = eval(evalable)
        if val is undefined or val is"" then return defaultValue
        number = parseInt(val, 10) 

        # Eventually, we probably want to store type information
        # for parameter values so that we can perform a more
        # knowledgable conversion, rather than trial-and-error
        return if isNaN(number) then val else number
      catch e
        # ...
        console.error('Exception occurred while evaluating property', content, evalable, e)
      
      
      #content
    else
      content

  # removes the current representation (if any) and substitutes @arg other as the new representation
  changeElementTo: (other) ->
    if@current
      @current.remove()
    @current = other

    redrawCoordinator.requestRedraw(true)


module.exports = BasicShape