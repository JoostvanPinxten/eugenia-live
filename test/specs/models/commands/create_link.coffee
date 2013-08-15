require = window.require

describe 'CreateLink', ->
  CreateLink = require('models/commands/create_link')
  Drawing = require('models/drawing')
  PaletteSpecification = require('models/palette_specification')

  beforeEach ->
    @palette = PaletteSpecification.create(json: '{
      "nodeShapes" : [
        {
          "name" : "Singleton",
          "elements" : [
            {
              "figure" : "rounded",
              "size" : { "width" : 100, "height" : 50 }
            }
          ]
        },
        {
          "name" : "multi",
          "elements" : [
            {
              "figure": "ellipse"
            },
            {
              "figure": "square"
            }
          ]
        }
      ],
      "linkShapes" : [
        {
          "name": "transition",
          "color": "black"
        }
      ]
    }').instantiate()

    @drawing = new Drawing()
    @parameters =
      shape: @palette.linkShapes().all()[0].id
      sourceId: "c1"
      targetId: "c2"
      segments:
        [
          point: {x: 5, y: 4}
          handleIn: {x: 3, y: 2}
          handleOut: {x: 1, y: 0}
        ]
    @command = new CreateLink(@drawing, @parameters)

  afterEach -> # only needed because Spine saves data to the web browser's local storage!
    @drawing.destroy() if @drawing

  it 'creates a new link when executed', ->
    @command.run()
    expect(@drawing.links().all().length).toBe(1)

    link = @drawing.links().first()
    expect(link.shape).toEqual(@parameters.shape)
    expect(link.sourceId).toEqual(@parameters.sourceId)
    expect(link.targetId).toEqual(@parameters.targetId)
    expect(link.segments).toEqual(@parameters.segments)
    
  it 'deletes the link when undone', ->
    @command.run()
    @command.undo()
    expect(@drawing.links().all().length).toBe(0)