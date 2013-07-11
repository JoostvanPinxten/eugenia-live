Spine = require('spine')
ChangeProperty = require('models/commands/change_property')

class Selection extends Spine.Controller
  events:
    "change input[data-property]": "updatePropertyValue"
  
  @item: null
  @selection: null
  @readOnly : false

  constructor: ->
    super
    @item.bind("update", @render)
    @render()
    
  render: =>
    if @item
      @selection = null
      @selection = @item.selection[0] if @item.selection.length is 1
      @definition = null
      @definition = @selection.getShape() if @selection
      @html require('views/drawings/selection')({selection: @selection, readOnly : @readOnly, definition : @definition})

  
  updatePropertyValue: (event) =>
    property = $(event.target).data('property')
    newValue = $(event.target).val()
    @commander.run(new ChangeProperty(@selection, property, newValue)) unless @readOnly
  
module.exports = Selection