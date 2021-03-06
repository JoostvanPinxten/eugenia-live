Spine = require('spine')
LinkTool = require('controllers/link_tool')
NodeTool = require('controllers/node_tool')
SelectTool = require('controllers/select_tool')
NodeShape = require ('models/node_shape')
LinkShape = require ('models/link_shape')

class Toolbox extends Spine.Controller
  events:
    "click a[data-tool-name]": "reactToToolSelection"
    "dblclick a": "showEditor"
  
  constructor: ->
    super
    @render()
    @createTools()
    @switchTo("select")
    
  createTools: ->
    # Remove any existing tools. This is a workaround
    # for when the user performs a refresh (F5) when on
    # the drawing page. It seems the Spine (possibly Substack)
    # redirects back to the drawings index, and then when 
    # the user next selects a drawing, another set of 
    # tools will be created
    paper.tools = []
    
    @tools =
      node:   new NodeTool(commander: @commander, drawing: @item)
      select: new SelectTool(commander: @commander, drawing: @item)
      link:   new LinkTool(commander: @commander, drawing: @item)
  
  render: =>
    @html require('views/drawings/toolbox')(@item) if @item
  
  showEditor: (event) =>
    event.preventDefault()
    link = $(event.currentTarget)
    toolName = link.data('toolName')
    
    unless toolName is 'select'
      @navigate("/drawings/#{@item.id}/#{toolName}s/#{link.data('toolShape')}")
  
  reactToToolSelection: (event) =>
    link = $(event.currentTarget)

    @switchTo(link.data('toolName'))
    @currentTool.setParameter('shape', link.data('toolShape'))
    # remove all other active selected tools (in the container with id 'toolbox')
    $("#toolbox li.active").removeClass("active")
    link.parent().addClass("active")
    event.preventDefault()
    
  switchTo: (toolName) =>
    throw "There is no tool named '#{toolName}'" unless @tools[toolName]
    @currentTool = @tools[toolName]
    @currentTool.activate()

    
module.exports = Toolbox