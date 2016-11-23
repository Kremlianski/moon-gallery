###*
#
# @class MMG.AJAX.Ajax
#
###


class MMG.AJAX.Ajax
  ###
  # the Singleton Pattern is used
  ###
  instance = {}
  Models = MMG.Data.Models
  Loader = MMG.Utility.ImageLoader
  Parser = MMG.Utility.Parser
  
  ###*
  # @method getParser
  # @param {String} gridId
  # @param {String} type
  # @public
  # a static method that is used to call the Parser instance
  ###
  @getAjax: (gridId, type = 'json')->

    instance[gridId] ?= new PrivatClass(gridId, type)


  ###*
  #
  # @class PrivateClass
  # 
  ###
  class PrivatClass

    ###*
    # @constructor
    # @param {String} gridId
    # @param {String} type
    #
    ###
    constructor: (@gridId, @type)->

      @data = []
      @model = Models[@gridId]
      @meta = @model.meta

      @ok = $.Deferred()

    _loadPics: =>
      self = @
      ###
      # jQuery Deferred object
      ###
      loaded = Loader.loadPics.call @

      ###
      # max timeout
      ###
#      _.delay loaded.resolve, @model.meta.maxWait
      
      
      ###
      # waits until all images are loaded
      # if an image is not loaded it is removed
      # frome the list
      ###
      loaded.then ->

        Models[self.gridId].meta = self.meta
        self.data = _.reject self.data, (el)->
          !el.height?

        self.ok.resolve()
        return
      return



    ###*
    #
    # @method load
    # @public
    # @param {String} url
    # @paran {Object} urlData
    ###
    load: (url, urlData = {}) =>

      @url = url if url?
      root = @meta.root
     
      root.height root.height()
      
      if @type == 'json' then @_loadJSON(url, urlData)
      else @_loadHTML(url, urlData)
      
      return

    ###*
    #
    # @method loadJSON
    # @public
    # @param {String} url
    # @paran {Object} urlData
    ###
    _loadJSON: (url, urlData) =>

      self = @
      $.getJSON url, urlData, (inData) ->
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
    # @method loadHTML
    # @public
    # @param {String} url
    # @paran {Object} urlData
    ###

    _loadHTML: (url, urlData) =>
      self = @
      $.get url, urlData, (data) ->

        fragment = $(document.createDocumentFragment())
        fragment.append data

        parser = Parser.getParser(self.gridId)
        self.data = parser.ajax(fragment)

        self._loadPics()
        return
      ,'html'
      return
      
    ###*
    #
    # @methos getDeferred
    # @public
    # @return {jQuery.Deferred}
    #
    ###

    getDeferred: =>
      @ok = $.Deferred()

    ###*
    #
    # @methos getData
    # @public
    # @return {Object}
    #
    ###
    getData: =>
      @data

      