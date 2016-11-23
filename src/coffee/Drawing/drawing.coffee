###*
#
# @class MMG.Drawing.Drawing
# 
# creates a canvas element and applies filters
###

class MMG.Drawing.Drawing

  models = MMG.Data.Models
  CanvasFilter = MMG.Filter.CanvasFilter

  ###*
  # @constructor
  # @param {String} gridId
  # @param {HTMLImageElement} item 
  ###
  constructor: (@gridId, item)->

    @model = models[@gridId]
    @meta = @model.meta
    @data = @model.data

    @retina = @meta.retina
    @filters = @meta.filters
    @twin = @meta.twin

    @container = item
    @sourceURL = @container.getAttribute 'src'
    

    @_loadImage @sourceURL, @_initializeCanvas

  ###*
  #
  # @method _loadImage
  # @private
  # @param {String} URL
  # @param {Function} callback - the function to be executed when 
  # the image is loaded
  #
  # loads the image
  ###
  _loadImage: (URL, callback) =>
    @imageObject = @container
    if @container.tagName.toLowerCase() != 'img'
      @imageObject = document.createElement('img')

    @imageObject.onload = callback.bind(this)
    if @container.tagName.toLowerCase() != 'img'
      @imageObject.src = URL
    if @imageObject.complete then callback()
    return

  ###*
  #
  # @method _initializeCanvas
  # @private
  ###
  _initializeCanvas: =>

    @imageObject.onload = null
    @rgb = {}
    @canvas = document.createElement('canvas')
    @containerParent = @container.parentNode
    @containerWidth = @container.offsetWidth
    @containerHeight = @container.offsetHeight
    @_insertAfter @container, @canvas
    @context = @canvas.getContext('2d')
    @canvas.width = @containerWidth
    @canvas.style.width = @container.style.width
    @canvas.height = @containerHeight
    @canvas.style.height = @container.style.height
    @canvas.style.top = @container.style.top
    @canvas.style.left = @container.style.left
    @canvas.style.maxWidth = @container.style.maxWidth
    @canvas.style.maxHeight = @container.style.maxHeight


    if window.devicePixelRatio > 1 and @retina > 0
      canvasWidth = @canvas.width
      canvasHeight = @canvas.height
      @canvas.width = canvasWidth * window.devicePixelRatio
      @canvas.height = canvasHeight * window.devicePixelRatio
      @canvas.style.width = canvasWidth
      @canvas.style.height = canvasHeight
      @context.scale window.devicePixelRatio, window.devicePixelRatio

    @_drawImage()
    
    return
    
    
  ###*
  #
  # @method _drawImage
  # @private
  ###

  _drawImage: =>

    affectedRectangle = @_getAffectedRectangle(@imageObject)
    @context.drawImage @imageObject, 0, 0,
    affectedRectangle.width, affectedRectangle.height

    if @meta.filters
      filter = CanvasFilter.getFilter @gridId
      filter.applyFilter(@context, @canvas)

    @_cleanMemory()
    return
    
  ###*
  #
  # @method _getAffectedRectangle
  # @private
  # @return {Object}
  #
  # returns an object with width and height of the image
  ###

  _getAffectedRectangle: =>
    rectangle = {}
    rectangle.width = @containerWidth
    rectangle.height = @containerHeight
    rectangle
    
  ###*
  #
  # @method _cleanMemory
  # @private
  ###

  _cleanMemory: =>
    unless @twin
      @imageObject.src = ''
      @containerParent.removeChild @container
      delete @container
      if @container != @imageObject
        delete @imageObject
      @container = null
      @imageObject = null

    delete @context

    @canvas = null
    @context = null
    @containerParent = null

    @containerWidth = null
    @containerHeight = null
    @sourceURL = null
    @rgb = null
    @filters = null
    return
    
  ###*
  #
  # @method _insertAfter
  # @private
  # @param {HTMLElement} referenceNode
  # @param {HTMLElement} newNode
  ###

  _insertAfter: (referenceNode, newNode) ->
    referenceNode.parentNode.insertBefore newNode, referenceNode.nextSibling
    return
