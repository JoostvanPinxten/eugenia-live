require('lib/setup')
require('lib/fetch_models')
#jQuery must be included, so that BaconJS can extend it with .asEventStream
require('jqueryify')
Spine = require('spine')
# require broke for the bacon module: should be
# Bacon = require('baconjs')
Bacon = require('baconjs/dist/Bacon')
Drawings = require('controllers/drawings')
Palettes = require('controllers/palettes')
Simulations = require('controllers/simulations')
Shape = require('models/shape')
NodeShape = require('models/node_shape')

###
class Person extends Spine.Model
  @configure "Person", "first_name", "last_name"

  fullName: -> 
    [@first_name, @last_name].join(' ')

class Character extends Person
  @configure "Character", "role"

wendy = new Person(first_name:"Wendy", last_name:"Darling")

peter = new Character(first_name:"Peter", last_name: "Pan", role : "Peter Pan")

another_wendy = Person.create(first_name:"Wendy", last_name:"Darling")
console.log "Wendy: Names should match, but don't" unless another_wendy.fullName() is wendy.fullName()

another_peter = Character.create(first_name:"Peter", last_name: "Pan", role : "Peter Pan")
console.log "Peter: Names should match, but don't" unless another_peter.fullName() is peter.fullName()
###

class App extends Spine.Stack
  controllers:
    palettes: Palettes
    drawings: Drawings
    simulations : Simulations
      
  routes:
    '/drawings/:d_id/palette' : 'palettes'
    '/drawings'               : 'drawings'
  
  default: 'drawings'
  
  constructor: ->
    super
    #console.log('test')
    
    #shape = Shape.create({name: 'test2'})
    #console.log(shape.name)
    #nodeShape = NodeShape.create({name: 'test3'})
    #console.log(nodeShape.name)

    #console.log('test')

    Spine.Route.setup()
    @navigate('/drawings')

    
module.exports = App  
