require = window.require

describe 'ChangeProperty', ->
  ChangeProperty = require('models/commands/change_property')
  Node = require('models/node')
  PaletteSpecification = require('models/palette_specification')

  beforeEach ->
    @palette = PaletteSpecification.create(json: '{
      "nodeShapes" : [
        {
          "name" : "Singleton", "properties": ["name"],
          "elements" : [
            {
              "figure" : "rounded",
              "size" : { "width" : 100, "height" : 50 }
            }
          ]
        },
        {
          "name" : "name",
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
    parameters = {shape: @palette.nodeShapes().all()[0].id}
    @node = new Node(parameters)
    @node.setPropertyValue("name", "old")
    @command = new ChangeProperty(@node, "name", "new")


  it "changes the value of the node's property", ->
    @command.run()
    expect(@node.getPropertyValue("name")).toBe("new")
  
  it "restores the value of the node's property when undone", ->
    @command.run()
    @command.undo()
  
    expect(@node.getPropertyValue("name")).toBe("old")