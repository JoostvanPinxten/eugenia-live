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
    # TODO: How can we make the values of the text-fields 
    # (which represent the properties) update together with 
    # the actual Element that's selected? 
    # We could perhaps use Bacon to bind to the 'update' 
    # event that is triggered by Spine, but I don't know
    # when to do this, and when to unsub from the 'update'
    # events

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