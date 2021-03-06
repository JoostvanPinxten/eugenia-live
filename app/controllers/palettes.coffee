JsonNotation = require("controllers/notations/json_notation")
EugeniaNotation = require("controllers/notations/eugenia_notation")

Spine.SubStack = require('lib/substack')
Drawing = require('models/drawing')
NodeShape = require('models/node_shape')
LinkShape = require('models/link_shape')
Palette = require('models/palette')

class Define extends Spine.Controller
  events:
    'submit form': 'define'
    'click [data-notation]' : 'changeNotation'
    'click #delete': 'delete'
    'click #cancel': 'cancel'
  
  constructor: ->
    super
    @notations = 
      json: new JsonNotation
      eugenia: new EugeniaNotation
    @notation = 'json'
    @active @change
  
  currentNotation: =>
    @notations[@notation]
  
  change: (params) ->
    @_item = null
    @params = params
    @type = @params.type[0..-2]
    @palette = Drawing.find(@params.d_id).palette()
    @render()

  changeNotation: (event) =>
    event.preventDefault()
    @notation = $(event.target).data('notation')
    @render()
  
  render: ->
    context = 
      serialisation: @serialise(@item())
      example: @serialise(@example())
      verb: @verb()
      type: @type
      notation: @notation
    @html require('views/palettes/define')(context)
    @installCodeMirrors()
  
  serialise: (o) =>
    if @type is 'node'
      @currentNotation().serialiseNode(@safe(o))
    else
      @currentNotation().serialiseLink(@safe(o))
  
  safe: (o) =>
    @removeIds(o.toJSON())
  
  item: =>
    if @type is 'node'
      @_item ?= @node()
    else
      @_item ?= @link()
      
  example: =>
    if @type is 'node'
      @_example ?= @example_node()
    else
      @_example ?= @example_link()
  
  example_node: =>
    new NodeShape
      name: "InitialState"
      elements: [
        "figure": "ellipse",
        "size": {"width": 10, "height": 10},
        "fillColor": "white",
        "borderColor": "black"
      ]
  
  example_link: =>
    new LinkShape
      name: "Link"
      color: "gray"
      style: "dash"
  
  installCodeMirrors: ->
    definitionOptions =
      lineNumbers: true
      matchBrackets: true
      mode: "application/#{@notation}"
    
    if @notation is 'json'
      definitionOptions['gutters'] = ["CodeMirror-lint-markers"]
      definitionOptions['lint'] = true
    
    exampleOptions =
      lineNumbers: true
      matchBrackets: true
      mode: "application/#{@notation}"
      readOnly: true
    
    d = CodeMirror.fromTextArea($("#" + @verb() + " #definition")[0], definitionOptions)
    e = CodeMirror.fromTextArea($("#" + @verb() + " #example")[0], exampleOptions)
    
    # The following is a workaround for broken CodeMirror editors on first load.
    # For some reason, the DOM is being manipulated after our code here. We should 
    # probably bind to an event that is fired once the browser has inserted the 
    # DOM elements generated by CodeMirror. As I can't find an appropriate event 
    # right now (window.onload and document.ready don't work), use a short timeout 
    # and then refresh the CodeMirror editors.
    window.setTimeout(( =>
      d.refresh()
      e.refresh()
    ), 10)

  
  define: (event) =>
    event.preventDefault()
    
    form = @extractFormData($(event.target)) 
    
    try
      nsData = @removeIds(@currentNotation().deserialise(form.definition))      
      @item().updateAttributes(nsData).save()
      @back()
    catch error
      @log(error.message)
  
  delete: (event) =>
    event.preventDefault()
    @item().destroy()
    @back()
  
  cancel: (event) =>
    event.preventDefault()
    @back()
    
  back: =>
    @navigate('/drawings/' + @params.d_id)

  removeIds: (o) =>
    delete o.id
    delete o.palette_id
    o

  extractFormData: (form) =>
    result = {}
    for key in form.serializeArray()
      result[key.name] = key.value
    result


class Create extends Define
  verb: =>
    "Create"
  
  node: =>
    new NodeShape(name: "TheNode", elements: [{figure:'rectangle',size:{width:100, height:20}}], palette_id: @palette.id)
    
  link: =>
    new LinkShape(name: "TheLink", palette_id: @palette.id, color: "black")


class Update extends Define
  verb: =>
    "Update"
  
  node: =>
    @palette.nodeShapes().find(@params.id)

  link: =>
    @palette.linkShapes().find(@params.id)


class Show extends Spine.Controller
  constructor: ->
    super
    @active @change

  change: (params) =>
    @item = Drawing.find(params.d_id).palette()
    @render()

  render: ->
    context =
      eugenia: new EugeniaNotation().serialisePalette(@item)

    @html require('views/palettes/show')(context)

class Palettes extends Spine.SubStack
  controllers:
    create: Create
    edit: Update
    show: Show
  
  routes:
    '/drawings/:d_id/palette'   : 'show'
    '/drawings/:d_id/:type/new' : 'create'
    '/drawings/:d_id/:type/:id' : 'edit'

module.exports = Palettes