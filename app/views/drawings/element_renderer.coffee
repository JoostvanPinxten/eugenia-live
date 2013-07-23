Spine = require('spine')


# FIXME: are these properly cleaned up? Could be the case that there is still some reference floating around somewhere?
class ElementRenderer  
  constructor: (@item) ->
    @item.bind("update", @refresh)
    @item.bind("render", @render)
    @item.bind("destroy", @remove)
    @item.bind("selected", @bringToFront)
    @item.getShape().bind("update", @remove)

    @representation = []

  render: =>
    #console.log 'rendering element', @item
    #old_el = @el
    @draw()
    @linkElementToModel(@el)
    
    #if old_el
    #  @el.selected = old_el.selected
    #  old_el.remove()
    paper.view.draw()
  
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

  sendToBack: =>
    paper.project.activeLayer.insertChild(0, @el)

  bringToFront: =>
    paper.project.activeLayer.addChild(@el)    
    
module.exports = ElementRenderer