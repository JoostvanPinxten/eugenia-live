Spine = require('spine')

class ElementOverview extends Spine.Controller

  constructor: ->
    super
    @render()
    @item.bind("update", @render)


  render: =>
    @html require('views/drawings/element_overview')(@item)

module.exports = ElementOverview