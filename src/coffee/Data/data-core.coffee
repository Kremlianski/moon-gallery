###*
#
# @class MMG.Data.Core
#
###
class MMG.Data.Core

  Models = MMG.Data.Models
  Loader = MMG.Utility.ImageLoader
  Parser = MMG.Utility.Parser

  ###*
  #
  # @constructor
  # @param {String} gridId
  #
  ###
  constructor: (@gridId) ->

    @data = []
    @model = Models[@gridId]
    @meta = @model.meta

    @_init()


  ###*
  #
  # @method _init
  # @private
  #
  ###
  _init: =>

    @_getData()
    return
    
  ###*
  #
  # @method _loadPics
  # @private
  #
  ###

  _loadPics: =>
    self = @
    ###
    jQuery Deferred object
    ###
    loaded = Loader.loadPics.call @

    ###
    max timeout
    ###
#    _.delay loaded.resolve, @model.meta.maxWait
    ###
     waits until all images are loaded
     if an image is not loaded it is removed
     frome the list
    ###
    loaded.then ->

      Models[self.gridId].meta = self.meta

      self.data = _.reject self.data, (el)->
        !el.height?
        

      Models[self.gridId].data = self.data


      Models[self.gridId].built.resolve()
      
      return
    return
    
  ###*
  #
  # @method _getData
  # @private
  # factory function
  ###
  _getData: ->

    switch
      when @model.meta.data then @_data()
      when @model.meta.url then @_ajax()
      else @_html()
      
    return
    
    
  ###*
  #
  # @method _ajax
  # @private
  # if by ajax
  ###
  _ajax: =>
    self = @
    $.getJSON @model.meta.url, (inData) ->
    
      if self.meta.jsonParser
        unless _.isFunction self.meta.jsonParser
          console.error 'jsonParser must be a function'
          self.data = {}
          return
        else 
          data = self.meta.jsonParser inData
          
      else data = inData
      
      if data[0].src
        self.data = data
      else
        self.data = data[0]
        if data[1] then self.meta.lastLoadedMeta = data[1]
        
      self._loadPics()
      return
    return
    
    
  ###*
  #
  # @method _data
  # @private
  # if Object
  ###
  _data: =>

    @data = @model.meta.data
    @_loadPics()
    return
    
    
  ###*
  #
  # @method _html
  # @private
  # if markup
  ###
  _html: =>

    parser = Parser.getParser(@gridId)
    @data = parser.parse()
    @_loadPics()
    return


