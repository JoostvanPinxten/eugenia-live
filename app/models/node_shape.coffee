Spine = require('spine')
Label = require('views/drawings/shapes/label')

Bacon = require('baconjs/dist/Bacon').Bacon
redrawCoordinator = require('views/drawings/redraw_coordinator')

Elements = require('views/drawings/shapes/elements')

class NodeShape extends Spine.Model
  @configure "NodeShape", "name", "properties", "label", "elements", "behavior", "observers"
  @belongsTo 'palette', 'models/palette'
  
  constructor: (attributes) ->
    super
    @properties or= []
    @createDelegates()
    @bind("update", @createDelegates)
    @bind("destroy", @destroyNodes)
  
  createDelegates: =>
    @_elements = new Elements(@elements)
    @_label = new Label(@label)
  
  defaultPropertyValues: =>
    defaults = {}
    defaults[property] = "" for property in @properties
    defaults
  
  displayName: =>
    @name.charAt(0).toUpperCase() + @name.slice(1)
  
  draw: (renderer) =>
    group = new paper.Group

    shape = @_elements.draw(renderer)
    group.addChild(shape)
    label = @_label.draw(renderer, group, shape)
    group.addChild(label)
    renderer.item.bind "propertyUpdate", (node)=>
      @_label.updateText(renderer.representation[@_label], renderer.item, shape) 
    group
      
  destroyNodes: ->
    node.destroy() for node in require('models/node').findAllByAttribute("shape", @id)
    
  refresh: (renderer) ->
    # console.log "refresh", renderer
    # can now be done based on the names of the paperId?!
    shape = renderer.representation[@_elements.paperId(renderer.item)]
    @_elements.refresh(renderer, @_elements, shape)
    @_label.updateText(renderer.representation[@_label], renderer.item, shape) 


module.exports = NodeShape