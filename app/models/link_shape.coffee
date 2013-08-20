Spine = require('spine')
Label = require('views/drawings/shapes/label')

class LinkShape extends Spine.Model
  @configure "LinkShape", "name", "properties", "color", "style", "label","width", "representation", "behavior"
  @belongsTo 'palette', 'models/palette'
  
  constructor: (attributes) ->
    super

    ExpressionEvaluator = require('models/helper/expression_evaluator')
    @evaluator = new ExpressionEvaluator

    @properties or= []
    @createDelegates()
    @bind("update", @createDelegates)    
    @bind("destroy", @destroyLinks)

  defaultPropertyValues: =>
    defaults = {}
    defaults[property] = "" for property in @properties
    defaults
  
  displayName: =>
    @name.charAt(0).toUpperCase() + @name.slice(1)

  ###
    @arg renderer The linkRenderer containing the link to be renderer
  ###
  draw: (renderer) =>
    
    #renderer.shapes[repr.id] = repr
    # now that we are certain that we have a representation, 
    # refresh it, so that it reflects the current value of its properties
    
    group = new paper.Group
    link = renderer.item

    path = new paper.Path(link.toSegments())
    renderer.representation[@id] = path
    
    ###
      Absolute rotation is problematic in Paper.js as I cannot find the right 
      property to inspect the current rotation; so this kludge allows us to 
      use the element and create a clone that is rotated with respect to the 
      original orientation.

      Watch https://groups.google.com/forum/#!topic/paperjs/R3O0peJPFc0 
      where this problem is discussed
    ###

    middle = new paper.Path([new paper.Point(15, -7), new paper.Point(0, 0), new paper.Point(15, 7)]);
    middle.strokeColor = "red"
    middle.name = "middle"
    middle.visible = false
    renderer.representation["middle"] = middle
    group.addChild(middle)
    group.addChild(path)
    label = @_label.draw(renderer, group, path)
    renderer.item.bind "propertyUpdate", (node)=>
      #console.log(label, path, label.parent == path.parent)
      @_label.updateText(renderer.representation[@_label], renderer.item, path) 
    renderer.item.bind "propertyUpdate", (node)=>
      #console.log(label, path, label.parent == path.parent)
      @refresh(renderer)

    group.addChild(label)
    @color or= "black"

    path.dashArray = [4, 4] if @style is "dash"

    # might also do the registration based on a manually triggered event
    
    #console.log(renderer.representation)
    group.addChild(path)
    @refresh(renderer)

    group
  
  destroyLinks: ->
    link.destroy() for link in require('models/link').findAllByAttribute("shape", @id)
  
  createDelegates: =>
    @_label = new Label(@label)

  defaultPropertyValues: =>
    defaults = {}
    defaults[property] = "" for property in @properties if @properties
    defaults

  refresh: (renderer) ->
    ###    for element in Object.keys(renderer.representation)
      @refreshOne(renderer, element, renderer.representation[element])

  refresh: (renderer) ->
    # console.log "refresh", renderer
    # can now be done based on the names of the paperId?!
    ###
    path = renderer.representation[@id]

    throw new Error("Incorrect program state; unable to reference path for link") unless path
    #console.error 'here'
    #@_elements.refresh(renderer, @_elements, shape)
    @_label.updateText(renderer.representation[@_label], renderer.item, path)

    if @color.indexOf('$')>= 0
      path.strokeColor = @evaluator.evaluate(renderer.item, @color)
    else
      path.strokeColor = @color

    @width or= 1
    path.strokeWidth = @width
    ###
      Position the middle elements at the middle of the line;
      * first rotate them in the direction of the tangent (direction from source to target)
      * then translate them according to the tangent's point and the elements' specified offset
      
      The rotation assumes that the representation is oriented to the left and should be rotated around the left-middle edge
    ###

    # position the middle element at the middle of the line
    middlePoint= path.getPointAt(path.length / 2)
    middleTangent= path.getTangentAt(path.length / 2)
    middleAngle = middleTangent.angle
    middle = renderer.representation["middle"]
    
    if renderer.representation["middleClone"]
      clone = renderer.representation["middleClone"]
      clone.remove()
    clone = middle.clone()

    # TODO This is not yet the right way to rotate around the left-center?
    clone.rotate(180+middleAngle, clone.bounds.leftCenter)
    clone.visible = true
    clone.position = middlePoint
    renderer.representation["middleClone"] = clone

    middle.position = middleTangent

  ###
    @arg representation The current representation of a link
  ###
  refreshOne: (representation) ->


module.exports = LinkShape