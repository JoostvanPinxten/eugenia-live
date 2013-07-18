Spine = require('spine')


# FIXME: are these properly cleaned up? Could be the case that there is still some reference floating around somewhere?
class ElementRenderer  
  constructor: (@item) ->
    @item.bind("update", @render)
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
    @item.unbind("update", @render)
    @item.unbind("destroy", @remove)
    @item.unbind("selected", @bringToFront)
    @item.getShape().unbind("update", @remove)

  sendToBack: =>
    paper.project.activeLayer.insertChild(0, @el)

  bringToFront: =>
    paper.project.activeLayer.addChild(@el)    
    
module.exports = ElementRenderer