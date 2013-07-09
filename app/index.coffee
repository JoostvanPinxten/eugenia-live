require('lib/setup')
require('lib/fetch_models')
#jQuery must be included, so that BaconJS can extend it with .asEventStream
require('jqueryify')
Spine = require('spine')
# require broke for the bacon module: should be
# Bacon = require('baconjs').Bacon
Bacon = require('baconjs/dist/Bacon').Bacon
Drawings = require('controllers/drawings')
Palettes = require('controllers/palettes')

class App extends Spine.Stack
  controllers:
    palettes: Palettes
    drawings: Drawings
      
  routes:
    '/drawings/:d_id/palette' : 'palettes'
    '/drawings'               : 'drawings'
  
  default: 'drawings'
  
  constructor: ->
    super
    Spine.Route.setup()
    @navigate('/drawings')

module.exports = App  
