Spine = require('spine')
Label = require('views/drawings/shapes/label')

class LinkShape extends Spine.Model
  @configure "LinkShape", "name", "properties", "color", "style", "label"
  @belongsTo 'palette', 'models/palette'
  
  constructor: (attributes) ->
    super
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
    group.addChild(path)
    label = @_label.draw(renderer, group, path)
    renderer.item.bind "propertyUpdate", (node)=>
      console.log(label, path, label.parent == path.parent)
      @_label.updateText(renderer.representation[@_label], renderer.item, path) 
    group.addChild(label)

    path.strokeColor = @color
    path.dashArray = [4, 4] if @style is "dash"

    # might also do the registration based on a manually triggered event
    renderer.representation[this] = path
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
    shape = renderer.representation[this]
    #console.error 'here'
    #@_elements.refresh(renderer, @_elements, shape)
    @_label.updateText(renderer.representation[@_label], renderer.item, shape)

  ###
    @arg representation The current representation of a link
  ###
  refreshOne: (representation) ->


module.exports = LinkShape