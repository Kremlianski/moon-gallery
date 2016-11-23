###*
#
# @class MMG.Utility.QueueSimple
###

class MMG.Utility.QueueSimple

  ###
  the Singleton Pattern is used
  ###
  instance = {}
  Queue = MMG.Utility.Queue
  
  ###*
  # @method getQueue
  # @param {String} gridId
  # @public
  # a static method that is used to call the QueueSimple instance
  ###

  @getQueue: (gridId)->

    instance[gridId] ?= new PrivateClass()

  ###*
  #
  # @class PrivateClass
  # 
  #
  ###
  class PrivateClass extends Queue
    ###*
    # @constructor
    # @param {String} gridId
    ###
    constructor: () ->
      super()
      
    ###*
    #
    # @method execute
    # @param {Function} func  
    # @public
    #
    # puts the function into the Queue
    ###
    execute: (func) =>

      if @size() == 0
        @put func
        @_slow()

      else @put func

    ###*
    # @method _slow
    # @private
    # executes func
    ###
    
    _slow: =>
      setTimeout =>

        func = @take()
        unless func then return

        func()
        @_slow()

      , 50


