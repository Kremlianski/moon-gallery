###*
#
# @class MMG.Utility.Parser
#
###
class MMG.Utility.Parser

  ###
  the Singleton Pattern is used
  ###

  instance = {}
  Models = MMG.Data.Models
  
  ###*
  # @method getParser
  # @param {String} gridId
  # @public
  # a static method that is used to call the Parser instance
  ###
  @getParser: (gridId)->

    instance[gridId] ?= new PrivateClass(gridId)
  ###*
  #
  # @class PrivateClass
  # 
  ###
  class PrivateClass
  
    ###*
    # @constructor
    # @param {String} gridId
    ###
    constructor: (@gridId) ->
      @model = Models[@gridId]
      @meta = @model.meta
      @data = @model.data
      @NS = @model.meta.NS
      @default = 'core'
      @callback = @model.meta.parser
      
    ###*
    #
    # @method parse
    # @public
    #
    ###

    parse: () =>
      if _.isFunction @callback then @_applyParser()
      else console.log 'the parser must be of function type!'
      
    ###*
    #
    # @method ajax
    # @public
    #
    ###

    ajax: (fragment) =>
      if _.isFunction @callback then @_applyParser(fragment)
      else console.log 'the parser must be of function type!'
      
    ###*
    #
    # @method _applyParser
    # @private
    # calls the parser function
    ###

    _applyParser: (root = @meta.root) =>

      @callback.call(@, root)

