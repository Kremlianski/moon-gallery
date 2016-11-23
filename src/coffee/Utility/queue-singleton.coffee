###*
#
# @class MMG.Utility.QueueSingleton
###

class MMG.Utility.QueueSingleton

  ###
  the Singleton Pattern is used
  ###
  instance = {}
  Queue = MMG.Utility.Queue
  
  ###*
  # @method getQueue
  # @param {String} gridId
  # @public
  # a static method that is used to call the QueueSingleton instance
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
    # @param {Array} func  First element is a function,
    #  second - a Row object
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
    # @method _check
    # @private
    # 
    ###

    _check: =>
      take =  @take()
      unless take then return false
      unless take[1].inView then take = @_check()
      else return take[0]
      
    ###*
    # @method _slow
    # @private
    # executes func[0] if func[1] is in view
    ###

    _slow: =>
      setTimeout =>

        func = @_check()
        unless func then return

        func()
        @_slow()

      , 50


