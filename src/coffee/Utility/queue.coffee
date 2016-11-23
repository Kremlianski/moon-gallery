###*
#
# @class MMG.Utility.Queue
# the general class for creating Queue objects
#
###

class MMG.Utility.Queue

  ###*
  # @constructor
  ###

  constructor: () ->
    @stac = new Array
    
  ###*
  #
  # @method take
  # @public
  # @return {Object}
  #
  ###

  take: =>
    @stac.shift()
    
  ###*
  #
  # @method put
  # @public
  # @param {Object} item the Object to be stored in the Queue
  #
  ###

  put: (item) =>
    @stac.push item
    @stac.length
    
  ###*
  # @method size
  # @public
  # @return {Integer}
  ###

  size: =>
    @stac.length