Spine = require('spine')
redrawCoordinator = require('views/drawings/redraw_coordinator')

# FIXME: are these properly cleaned up? Could be the case that there is still some reference floating around somewhere?
class ElementRenderer  
  constructor: (@item) ->
    @item.bind("update", @render)
    @item.bind("render", @render)
    @item.bind("destroy", @remove)
    @item.bind("selected", @bringToFront)
    @item.getShape().bind("update", @remove)

    @representation = []

  render: =>
#    console.error 'rendering element', @item.paperId()
    @draw()
    @linkElementToModel(@el)
    
    redrawCoordinator.requestRedraw()
  
  linkElementToModel: (e) =>
    e.model = @item
    @linkElementToModel(c) for c in e.children if e.children
      
  draw: =>
    throw "No draw method has been defined for: #{@item}"
        
  remove: =>
    @el.remove()

    # cleanup any bindings we may have on this object
    @item.unbind("update", @render)
    @item.unbind("render", @render)
    @item.unbind("destroy", @remove)
    @item.unbind("selected", @bringToFront)
    @item.getShape().unbind("update", @remove)

  refresh: =>
    # move the element to it's new position, without re-rendering the whole bunch
    @item.nodeShape().refresh(@)

  # Moves a Paper element to the back by inserting it as a toplevel child
  sendToBack: (deep = true)=>
    if deep
      paper.project.activeLayer.insertChild(0, @el)
    else
      @el.parent.insertChild(0, @el)
  
  # Moves a Paper element to the top by adding it as a toplevel child
  bringToFront: (deep) =>
    #console.log('bring to front', @el.parent)
    if deep
      paper.project.activeLayer.addChild(@el)
    else
      @el.parent.insertChild(0, @el)
    
module.exports = ElementRenderer