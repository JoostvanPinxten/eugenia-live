Spine = require('spine')
Tool = require('controllers/tool')
DeleteElement = require('models/commands/delete_element')
Node = require('models/node')
Link = require('models/link')

class ElementOverview extends Spine.Controller

  # @item is an instance of a Drawing
  events: 
    "click .delete[data-node]": "deleteNode",
    "click .delete[data-link]": "deleteLink"

  constructor: ->
    super
    @render()
    @item.bind("update", @render)

  run: (command, options={undoable: true}) ->
    @commander.run(command, options)

  render: =>
    @html require('views/drawings/element_overview')(@item)

  deleteNode: (event) =>
    nodeId = $(event.currentTarget).data('node')
    node = Node.find(nodeId)

    @deleteElement(node)


  deleteLink: (event) =>
    linkId = $(event.currentTarget).data('link')
    link = Link.find(linkId)

    @deleteElement(link)

  deleteElement: (element) ->
    if element
      #TODO: confirm?
      @run(new DeleteElement(@item, element))
      @item.clearSelection()
      # how to force an update of the view?
      #@item.renderer.render()
    else
      console.warn('Trying to remove an element which doesn\'t exist?!')

module.exports = ElementOverview