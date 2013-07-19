# Spine = require('spine')
PaletteSpecification = require('models/palette_specification')
Drawing = require('models/drawing')

Spine.SubStack = require('lib/substack')
CanvasRenderer = require('views/drawings/canvas_renderer')
Toolbox = require('controllers/toolbox')
Selection = require('controllers/selection')
ElementOverview = require('controllers/element_overview')
#Simulation = require('controllers/simulation')
Commander = require ('models/commands/commander')


class Index extends Spine.Controller
  events:
    'submit form': 'create'
    'click .delete': 'delete'

  constructor: ->
    super
    @active @render
  
  render: ->
    context =
      drawings: Drawing.all()
      palette_specs: PaletteSpecification.all()
    #@log(context)
    @html require('views/drawings/index')(context)
    
  create: (event) =>
    event.preventDefault()
    
    form = @extractFormData($(event.target)) 
    item = Drawing.create(name: form.name)
    
    if item and item.save()
      palette = PaletteSpecification.find(form.palette_specification_id).instantiate()
      palette.drawing_id = item.id
      palette.save()
      @navigate '/drawings', item.id
    else
      @$('input#name').focus()

  delete: (event) =>
    button = @$(event.currentTarget)
    id = button.data('id')
    drawing = Drawing.find(id)
    if confirm("Are you sure you want delete drawing '#{drawing.name}'?")
      Drawing.destroy(id)
      @render()

  extractFormData: (form) =>
    result = {}
    for key in form.serializeArray()
      result[key.name] = key.value
    result

class Show extends Spine.Controller
  events:
    'click [data-mode]' : 'changeMode'      

  constructor: ->
    super
    @active @change
  
  change: (params) =>
    # LoggingCommander = require ('models/commands/logging_commander')
    # @commander = new LoggingCommander(new Commander())
    @commander = new Commander()
    # i think we should rename item to drawing, makes more sense here, or is this Spine specific?
    @item = Drawing.find(params.id)
    @item.clearSelection()
    #@log "Palette: #{@item.palette().id}"
    @item.trigger("update")
    @render()

  render: ->
    @html require('views/drawings/show')(@item)
    if @item
      new CanvasRenderer(drawing: @item, canvas: @$('#drawing')[0])
      @toolbox = new Toolbox(commander: @commander, item: @item, el: @$('#toolbox'))  
      #@simulation = new Simulation(commander: @commander, item: @item, el: @$('#simulation'))  
      @selection = new Selection(commander: @commander, item: @item, el: @$('#selection'))
      @overview = new ElementOverview(item: @item, el: @$('#element-overview'))

  deactivate: ->
    super
    @toolbox.release() if @toolbox

  changeMode: (event) =>
    event.preventDefault()
    @mode = $(event.target).data('mode')
    @navigate('/simulate', @item.id) if @mode is 'simulate'    

class Drawings extends Spine.SubStack
  controllers:
    index: Index
    show: Show
    
  routes:
    '/drawings'     : 'index'
    '/drawings/:id' : 'show'
  default: 'index'

module.exports = Drawings
