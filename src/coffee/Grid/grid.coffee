###*
#
# @class MMG.Grid.Grid
#
# The main class of this script
#
# @example
# 
# var grid = new MMG.Grid.Grid(options);
# 
###


class MMG.Grid.Grid


  Builder = MMG.Data.ModelBuilder
  Models = MMG.Data.Models
  Size = MMG.Utility.NaturalSize
  View = MMG.View.View
  Ajax = MMG.AJAX.Ajax
  Lightbox = MMG.Lightbox.Lightbox
  LightboxSwipe = MMG.Lightbox.LightboxSwipe
  Template = MMG.View.Template
  
  ###*
  #
  # @constructor
  # @param {Object} options
  #
  ###
  
  constructor: (@options)->

    @gridId = _.uniqueId('model_')
    @model = {}
    @ajax = null
    @view = null

    @_init()
    
  ###*
  #
  # @method _init
  # @private
  ###

  _init: =>
    @_setArrayIndexOf()
    Size.set()
    @_setModel()
    @_setLightbox()
    
    
    
    return

  ###*
  #
  # @method _setModel
  # @private
  ###
  _setModel: =>

    new Builder @gridId, @options
    @model = Models[@gridId]
    self = @

    @model.built.then ->

      self._makeGrid()
      return
    return
    
  ###*
  #
  # @method _makeView
  # @private
  ###
  _makeView: ->

    @view = new View @gridId
    
    return

  ###*
  #
  # @methos loadByAjax
  # @public
  # @param {String} url 
  # @param {Object} urlData The object of data or {}
  # @param {String} type 'json'(default) or 'html'
  #
  # @example
  #
  #  grid.loadByAjax('json/load2.json');
  #
  ###
  loadByAjax: (url, urlData, type) =>

    @ajax = Ajax.getAjax @gridId, type

    loaded = @ajax.getDeferred()
    @ajax.load(url, urlData)


    loaded.then @_resetView
    return

  ###*
  #
  # @method _resetView
  # @private
  #
  ###
  _resetView: =>
    data = @ajax.getData()

    @view.add(data)
    return
    


  ###*
  #
  # @method _setLightbox
  # @private
  # creates the Lightbox
  ###
  _setLightbox: =>
    if @model.meta.lightbox
      
      if @model.meta.lightbox.swipe
        @lb = new LightboxSwipe @gridId, @model.meta
        
      else   
        @lb = new Lightbox @gridId, @model.meta
        
      @lb.open = _.wrap @lb.show, (func, index) =>
      
        if @model.meta.excludable
          data = _.reject @model.data, (item) -> item.excluded
          index1 = _.map data, (item) ->
            item.image?.attr 'data-image-id'
          .indexOf index
          
        else
          data = @model.data
          index1 = index
        
      
        @lb.setData data
        func index1
      
      @model.meta.root.on 'click',  @model.meta.NSclass + 'link', (event) =>
      
        if $(event.target).hasClass "#{@model.meta.NS}-img"
          image = $(event.target)
        else
          image = $(event.target).parents ".#{@model.meta.NS}-img"

        if @model.meta.excludable and image.hasClass @model.meta.excludeClass then return
        
        event.preventDefault()
        
        
          
        index = image.attr('data-image-id')
        
        @lb.open index
        return
    return
    
  ###*
  #
  # @method _makeGrid
  # @private
  # 
  ###
  _makeGrid: =>
  
    meta = @model.meta
    root = meta.root
    root.wrap "<div class='#{meta.NS}-grid-wrapper'></div>"
    root.width root.width()
    .addClass meta.NS + '-grid'
    
    wrapper = root.parent()

    wrapper
    .css
      width: '100%'
      overflow: 'hidden'
      
    klass = meta.gridClass


    root.addClass klass if klass
    root.addClass meta.NS+'-twin' if meta.twin

    root.addClass meta.NS+'-mb' if meta.isMobile

    root.addClass meta.NS+'-ie9' if meta.ieVer == 9
    root.addClass meta.NS+'-ie8' if meta.ieVer == 8
    
    @_makeView()
    return
  
  
  ###*
  #
  # Factory function for creating colorBox or photoSwipe or prettyPhoto
  #
  # @method getExternalLightbox
  # @public
  # @param {String} lb - may be: 'colorbox', 'photoswipe', 'prettyphoto'
  # @param {Object} options - native lightbox options
  # @param {Object} cbs - callback functions
  # @return lightbox object
  #
  ###
  getExternalLightbox: (lb, options, cbs) =>
  
    switch lb
      when 'colorbox' 
        MMG.Lightbox.External.colorBox.call @, options, cbs
      when 'prettyphoto'
        MMG.Lightbox.External.prettyPhoto.call @, options, cbs
      when 'photoswipe'
        MMG.Lightbox.External.photoSwipe.call @, options, cbs
      else console.error 'Wrong lightbox parameter!'
  
  
  getLastLoadedMeta: () =>

    return @model.meta?.lastLoadedMeta
  
  getLightbox: ()->
    @lb
    
  getLoader: ()->
    @model.meta.loader
  
  
  ###*
  #
  # if Array.prototype.indexOf method doesn't exist (ie8)
  # this methord will solve the problem
  #
  ###
  _setArrayIndexOf: ->
    if !Array::indexOf

      Array::indexOf = (searchElement, fromIndex) ->
        k = undefined
        if this == null
          throw new TypeError('"this" is null or not defined')
        O = Object(this)
        len = O.length >>> 0
        if len == 0
          return -1
        n = +fromIndex or 0
        if Math.abs(n) == Infinity
          n = 0
        if n >= len
          return -1
        k = Math.max((if n >= 0 then n else len - Math.abs(n)), 0)
        while k < len
          if k of O and O[k] == searchElement
            return k
          k++
        -1
  
