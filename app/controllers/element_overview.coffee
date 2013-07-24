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
    "click .select[data-node]": "selectNode",
    "click .select[data-link]": "selectLink"

  constructor: ->
    super
    @render()
    @item.bind("update", @render)

  run: (command, options={undoable: true}) ->
    @commander.run(command, options)

  render: =>
    @html require('views/drawings/element_overview')(@item)

  deleteNode: (event) =>
    node = @extractNodeFromEvent(event)
    @deleteElement(node)

  extractNodeFromEvent: (event) ->
    nodeId = $(event.currentTarget).data('node')
    Node.find(nodeId)

  extractLinkFromEvent: (event) ->
    linkId = $(event.currentTarget).data('link')
    Link.find(linkId)

  deleteLink: (event) =>
    link = @extractLinkFromEvent(event)
    @deleteElement(link)

  selectNode: (event) =>
    @item.clearSelection()
    
    node = @extractNodeFromEvent(event)
    @item.select(node)

  selectLink: (event) =>
    @item.clearSelection()

    link = @extractLinkFromEvent(event)
    @item.select(link)

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