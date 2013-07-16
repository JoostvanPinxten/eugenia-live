Spine = require('spine')
Label = require('models/helpers/label')

class LinkShape extends Spine.Model
  @configure "LinkShape", "name", "properties", "color", "style", "label"
  @belongsTo 'palette', 'models/palette'
  
  constructor: (attributes) ->
    super
    @createDelegates()
    @bind("update", @createDelegates)    
    @bind("destroy", @destroyLinks)

  
  displayName: =>
    @name.charAt(0).toUpperCase() + @name.slice(1)
    
  draw: (link) =>
    
    path = new paper.Path(link.toSegments())
    group = @_label.draw(link, path)

    path.strokeColor = @color
    path.dashArray = [4, 4] if @style is "dash"
    group
  
  destroyLinks: ->
    link.destroy() for link in require('models/link').findAllByAttribute("shape", @id)
  
  createDelegates: =>
    @_label = new Label(@label)

  defaultPropertyValues: =>
    defaults = {}
    defaults[property] = "" for property in @properties if @properties
    defaults

module.exports = LinkShape