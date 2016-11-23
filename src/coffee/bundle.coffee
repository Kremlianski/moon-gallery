###*

Moon Mega Grid

@author Alexandre Kremlianski (kremlianski@gmail.com)
 
@version 2.9

@requires jQuery
@requires Underscore.js
@requires jquery-scrollstop


###

window.MMG =
  Grid: {}
  Data: {}
  Utility: {}
  View: {}
  AJAX: {}
  Drawing: {}
  Filter: {}
  Templates: {}
  Lightbox: {}
  Lightboxes: {}
  
###
  Namespace for all classes of this project
###
  
MMG = window.MMG
###*
#
# @class MMG.Utility.StyleDetector
#
# Detects CSS Style Support
#
# inspired by Ryan Morr
# http://ryanmorr.com/detecting-css-style-support/
#
#
# You can use this class in your templates
###


class MMG.Utility.StyleDetector

  ###*
  #
  # @method isStyleSupported
  # @public
  # @static
  # @param {String} prop - tested property
  # @param {String} value - "inherit", if no value is supplied
  #
  ###
  
  @isStyleSupported: (prop, value) ->
    el = window.document.createElement('div')
    camelRe = /-([a-z]|[0-9])/ig
    ###
    # If no value is supplied, use "inherit"
    ###
    value = if arguments.length == 2 then value else 'inherit'
    ###
    # Try the native standard method first
    ###
    if 'CSS' of window and 'supports' of window.CSS
      return window.CSS.supports(prop, value)
    ###
    # Check Opera's native method
    ###
    if 'supportsCSS' of window
      return window.supportsCSS(prop, value)
    ###
    # Convert to camel-case for DOM interactions
    ###
    camel = prop.replace(camelRe, (all, letter) ->
      (letter + '').toUpperCase()
    )
    ###
    # Check if the property is supported
    ###
    support = camel of el.style
    ###
    # Assign the property and value to invoke
    # the CSS interpreter
    ###
    el.style.cssText = prop + ':' + value
    ###
    # Ensure both the property and value are
    # supported and return
    ###
    support and el.style[camel] != ''



###
the Object that will store all data
###
MMG.Data.Models = {}

###*

The object with supported canvas filters

###
MMG.Filter.CanvasFilters =

  grayscale: ->
    v = 0.2126 * @rgb.r + 0.7152 * @rgb.g + 0.0722 * @rgb.b
    @rgb.r = @rgb.g = @rgb.b = v
    return

  brightness:(adjust) ->
  
    ###
    Range is -100 to 100
    ###
  
    adjust = Math.floor(adjust * 2.55)
    @rgb.r += adjust
    @rgb.g += adjust
    @rgb.b += adjust
    return

  sepia: ->
    r = @rgb.r * 0.393 + @rgb.g * 0.769 + @rgb.b * 0.189
    g = @rgb.r * 0.349 + @rgb.g * 0.686 + @rgb.b * 0.168
    b = @rgb.r * 0.272 + @rgb.g * 0.534 + @rgb.b * 0.131

    @rgb.r = r
    @rgb.g = g
    @rgb.b = b
    return

  contrast: (adjust) ->
    ###
      Range is -100 to 100
    ###
    adjust = ((adjust + 100) / 100) ** 2
    @rgb.r = ((@rgb.r / 255 - 0.5) * adjust + 0.5) * 255
    @rgb.g = ((@rgb.g / 255 - 0.5) * adjust + 0.5) * 255
    @rgb.b = ((@rgb.b / 255 - 0.5) * adjust + 0.5) * 255
    return

  vibrance: (adjust) ->
    ###
      -100<adjust<100
    ###
    adjust *= -1
    amt = undefined
    avg = undefined
    max = undefined
    max = Math.max(@rgb.r, @rgb.g, @rgb.b)
    avg = (@rgb.r + @rgb.g + @rgb.b) / 3
    amt = Math.abs(max - avg) * 2 / 255 * adjust / 100
    if @rgb.r != max
      @rgb.r += (max - (@rgb.r)) * amt
    if @rgb.g != max
      @rgb.g += (max - (@rgb.g)) * amt
    if @rgb.b != max
      @rgb.b += (max - (@rgb.b)) * amt
    return

  saturate: (adjust) ->
    ###
     Range is -100 to 100
    ###
    adjust *= -0.01
    max = undefined
    max = Math.max(@rgb.r, @rgb.g, @rgb.b)
    if @rgb.r != max
      @rgb.r += (max - (@rgb.r)) * adjust
    if @rgb.g != max
      @rgb.g += (max - (@rgb.g)) * adjust
    if @rgb.b != max
      @rgb.b += (max - (@rgb.b)) * adjust
    return

  colorize: (red, green, blue, adjust) ->
    ###
      0 to 100
    ###
    @rgb.r -= (@rgb.r - red) * adjust / 100
    @rgb.g -= (@rgb.g - green) * adjust / 100
    @rgb.b -= (@rgb.b - blue) * adjust / 100
    return

  noise: (adjust) ->
    ###
      1 - 100
    ###

    randomRange = (min, max, getFloat) ->
      rand = undefined
      if getFloat == null
        getFloat = false
      rand = min + Math.random() * (max - min)
      if getFloat
        rand.toFixed getFloat
      else
        Math.round rand

    adjust = Math.abs(adjust) * 2.55
    rand = randomRange(adjust * -1, adjust)
    @rgb.r += rand
    @rgb.g += rand
    @rgb.b += rand
    return


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
###*
#
# @class MMG.Filter.CanvasFilter
# 
#
###

class MMG.Filter.CanvasFilter
  ###
  the Singleton Pattern is used
  ###
  
  instance = {}
  models = MMG.Data.Models
  filters = MMG.Filter.CanvasFilters
  
  ###*
  # @method getFilter
  # @param {String} gridId
  # @public
  # a static method that is used to call the CanvasFilter object
  ###

  @getFilter: (gridId)->

    instance[gridId] ?= new PrivatClass(gridId)
  
  
  ###*
  #
  # @class PrivateClass
  # 
  #
  ###
  class PrivatClass
  
    ###*
    # @constructor
    # @param {String} gridId
    ###
    
    constructor: (@gridId)->
      @model = models[@gridId]
      @meta = @model.meta
      @rgb = {}
      @filtersList = @_loadFilters()
      
      
    ###*
    #
    # @method _loadFilters
    # @private
    # @return {Function}
    #
    ###

    _loadFilters: =>

      func = ''
      i = 0
      while i < @meta.filters.length
        func += 'filters[this.meta.filters[' + i + '][0]].apply(this, this.meta.filters[' + i + '][1]);'
        i++

      new Function 'filters', func

    ###*
    #
    # @method applyFilter
    # @public
    # @param {RenderingContext} context
    # @param {HTMLCanvasElement} canvas
    #
    ###
    applyFilter: (context, canvas)=>

      imageData = context.getImageData(0, 0, canvas.width, canvas.height)

      d = imageData.data

      i = 0
      while i < d.length
        @rgb.r = d[i]
        @rgb.g = d[i + 1]
        @rgb.b = d[i + 2]

        @filtersList.call this, filters

        d[i] = @rgb.r
        d[i + 1] = @rgb.g
        d[i + 2] = @rgb.b
        @rgb = {}
        i += 4
      context.putImageData imageData, 0, 0
      return

###*
#
# @class MMG.View.Template
#
#
# When the instance is created the template 
# that has been specified in the options object
# will be compiled by Underscore function 'template'
# 
#
###

class MMG.View.Template

  ###
  the Singleton Pattern is used
  ###

  instance = {}
  models = MMG.Data.Models
  
  ###*
  # @method getTemplate
  # @param {String} gridId
  # @public
  # a static method that is used to call the Template object
  ###

  @getTemplate: (gridId, name, type = 'g')->
    
    adress = '' + gridId + name + type
    instance[adress] ?= new PrivatClass(gridId, name, type)
  
    
    
  ###*
  #
  # @class PrivateClass
  # 
  #
  ###
  class PrivatClass
    ###*
    # @constructor
    # @param {String} adress
    ###
    constructor: (@gridId, @name, @type)->
      @model = models[@gridId]
      @meta = @model.meta
      @compiled = null

      @_setTemplate()

      @_compile()
      
      @_callCallback()
      
    ###*
    # @method getCompiled
    # @public
    #
    # returns the compiled template
    #
    ###

    getCompiled: =>
      @compiled
      
      
    ###*
    # @method _compile
    # @private
    #
    ###

    _compile: =>

      @compiled = _.template @template
      return

    _setTemplate: ->
    
      switch @type
      
        when 'g'
          @_setGTemplate()
        when 'l'
          @_setLTemplate()
          
          
    _setGTemplate: ->
      
      @template = MMG.Templates[@name].template
      @callback = MMG.Templates[@name].callback

      if @meta.isMobile
        if MMG.Templates[@name].mobile
          if MMG.Templates[@name].mobile.template
            @template = MMG.Templates[@name].mobile.template
          if MMG.Templates[@name].mobile.callback
            @callback = MMG.Templates[@name].mobile.callback

      if 0 < @meta.ieVer <= 9
        if MMG.Templates[@name].ie9
          if MMG.Templates[@name].ie9.template
            @template = MMG.Templates[@name].ie9.template
          if MMG.Templates[@name].ie9.callback
            @callback = MMG.Templates[@name].ie9.callback

      if @meta.ieVer == 8
        if MMG.Templates[@name].ie8
          if MMG.Templates[@name].ie8.template
            @template = MMG.Templates[@name].ie8.template
          if MMG.Templates[@name].ie8.callback
            @callback = MMG.Templates[@name].ie8.callback
            
      return
      
      
    _setLTemplate: ->
    
      @template = MMG.Lightboxes[@name].template
      @callback = MMG.Lightboxes[@name].callback
      
      if @meta.isMobile
        if MMG.Lightboxes[@name].mobile
          if MMG.Lightboxes[@name].mobile.template
            @template = MMG.Lightboxes[@name].mobile.template
          if MMG.Lightboxes[@name].mobile.callback
            @callback = MMG.Lightboxes[@name].mobile.callback

      if 0 < @meta.ieVer <= 9
        if MMG.Lightboxes[@name].ie9
          if MMG.Lightboxes[@name].ie9.template
            @template = MMG.Lightboxes[@name].ie9.template
          if MMG.Lightboxes[@name].ie9.callback
            @callback = MMG.Lightboxes[@name].ie9.callback

      if @meta.ieVer == 8
        if MMG.Lightboxes[@name].ie8
          if MMG.Lightboxes[@name].ie8.template
            @template = MMG.Lightboxes[@name].ie8.template
          if MMG.Lightboxes[@name].ie8.callback
            @callback = MMG.Lightboxes[@name].ie8.callback
    
    _callCallback: ->
      if @callback and _.isFunction @callback
        @callback.call @
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



###*
#
# @class MMG.Drawing.DrawingSVG
# 
# creates a SVG element
###

class MMG.Drawing.DrawingSVG

  models = MMG.Data.Models
  
  ###*
  # @constructor
  # @param {String} gridId
  # @param {Object} item - the object with data for this item
  # @param {HTMLElement} parent - the image parent element
  ###

  constructor: (@gridId, item,  parent)->

    @model = models[@gridId]
    @meta = @model.meta


    @retina = @meta.retina


    @filters = @meta.svgFiltersId
    @image = item
    @url = @image.src
    @width = @image.newWidth
    @height = @image.newHeight

    @containerParent = parent

    @_initializeSVG()
    
    
  ###*
  # @method _initializeSVG
  # @private
  ###

  _initializeSVG: =>
    @svg = document.createElementNS 'http://www.w3.org/2000/svg', 'svg'

    @containerWidth = Math.round @width
    @containerHeight = Math.round @height



    @svg.setAttribute 'width', @containerWidth
    @svg.setAttribute 'height', @containerHeight
    @svg.setAttribute 'viewBox', '0 0 ' + @containerWidth + ' ' + @containerHeight
    @containerParent.appendChild @svg
    @svg.width = @containerWidth
    @svg.style.width = @containerWidth
    @svg.height = @containerHeight
    @svg.style.height = @containerHeight

    @svg.viewBox = '0 0 ' + @svg.width + ' ' + @svg.height

    if window.devicePixelRatio > 1 and @retina > 0
      svgWidth = @svg.width
      svgHeight = @svg.height
      @svg.width = svgWidth * window.devicePixelRatio
      @svg.height = svgHeight * window.devicePixelRatio
      @svg.style.width = svgWidth
      @svg.style.height = svgHeight


    @_drawImage()
    return

  ###*
  # @method _drawImage
  # @private
  ###
  
  _drawImage: =>

    image = document.createElementNS('http://www.w3.org/2000/svg', 'image')
    $(image).attr
      width: @containerWidth
      height: @containerHeight
      filter: "url(##{@filters})"
    image.setAttributeNS 'http://www.w3.org/1999/xlink', 'xlink:href', @url

    @svg.appendChild image
    @_cleanMemory()
    return
    
  ###*
  # @method _cleanMemory
  # @private
  ###
  _cleanMemory: =>

    @retina = null

    @svg = null
    @filters = null
    @image = null
    @url = null
    @width = null
    @height = null
    @containerParent = null

    return


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

###*
#
# the object that stores data about rows
###

MMG.Data.Rows = {}
###*
#
# @class MMG.View.Row
#
###

class MMG.View.Row

  models = MMG.Data.Models
  rows = MMG.Data.Rows
  Img = MMG.View.Image
  Drawing = MMG.Drawing.Drawing
  DrawingSVG = MMG.Drawing.DrawingSVG
  Queue = MMG.Utility.QueueSingleton
  
  ###*
  #
  # @constructor
  # @param {String} gridId
  #
  ###

  constructor: (@gridId) ->

    @model = models[@gridId]
    @meta = @model.meta
    @data = @model.data
    @rowData =
      images: []
      finished: on
      row: null

    @row = null
    @rows = rows[@gridId].data
    @rowMeta = rows[@gridId].meta
    @rowId = @rows.length
    @images = []
    @width=0
    @height = @meta.minHeight
    @queue = Queue.getQueue(@gridId)

    @_makeRow()
    @_register()
    
    
  ###*
  #
  # @method _makeRow
  # @private
  #
  # creates html-element
  #
  ###

  _makeRow: =>

    rowString = "<div class='#{@meta.NS}-row'></div>"
    @row = $(rowString)
    @rowData.row = @row
    
    return

  ###*
  #
  # @method calculate
  # @public
  # @param {Object} item
  #
  #
  ###
  calculate: (item) =>

    minWidth = @meta.minHeight * item.ratio

    @rowData.width = @width += minWidth + @meta.margin

    item.newWidth = minWidth
    item.newHeight = @meta.minHeight
    on

  ###*
  #
  # @method _register
  # @private
  #
  ###
  _register: =>
    @rows[@rowId] = @rowData
    return
    
    
  ###*
  #
  # @method registerImage
  # @public
  # @param {Integer} i
  #
  ###

  registerImage: (i)=>
    @rowData.images.push(i)
    return
    
    
  ###*
  #
  # @method needNew
  # @public
  # @return {Boolean}
  #
  # returns 'true' if the row needs more items
  #
  ###


  needNew: =>
    width = @width-@meta.margin
    return no if @meta.root.width() - width > 0
    on


  ###*
  #
  # @method resize
  # @public
  #
  # When the row width is bigger then expected
  # this method specifies a new width and a new height
  # for every item in the row
  #
  ###
  resize: =>

    self = @
    margin = @meta.margin
    realWidth = @width - margin
    minHeight = newHeight = @meta.minHeight

    root = @meta.root

    length = @rowData.images.length
    if realWidth > root.width()
      newHeight = (root.width()-margin*(length-1)) /
      (realWidth-margin*(length-1)) * minHeight



      rowElements = _.map @rowData.images, (item)->
        image = self.data[item]
        ratio = image.ratio
        newWidth = newHeight * ratio

        image.newWidth = newWidth
        image.newHeight = newHeight

        sizeClass = self._getClass(newWidth)

        image.image.css
          width: newWidth
          height: newHeight

        image.image.addClass sizeClass if sizeClass?

        $("#{self.meta.NSclass}fs", image.image.get(0)).css
          width: newWidth
          height: newHeight

        image

      @row.css
        height: newHeight + 'px'
        width: root.width() + 100 + 'px'
        display: 'block'
        'margin-bottom': margin + 'px'

      @rowData.finished = on

    else
      _.each @rowData.images, (item) ->
        image = self.data[item]

        image.image.css
          width: image.newWidth
          height: newHeight

        $("#{self.meta.NSclass}fs", image.image.get(0)).css
          width: image.newWidth
          height: newHeight
        return

      @row.css
        height: newHeight + 'px'
        width: root.width() + 100 + 'px'
        display: 'block'
        'margin-bottom': margin + 'px'
        

    @rowData.height = newHeight

    if @rowId == 0
      @rowData.top = 0
    else
      @rowData.top = @meta.margin + @rows[@rowId - 1].top + newHeight

    @rowMeta.scrollTop = $(document).scrollTop()
    @rowMeta.scrollLeft = $(document).scrollLeft()
    @rowData.inView = @_isInView()

    unless @rowData.inView then @_hideImages()
    return
    
  ###*
  #
  # @method _getClass
  # @private
  # @param {Integer} width
  #
  # specifies a 'size class': 
  # 'mmg-small' or 'mmg-middle' or undefined
  ###

  _getClass: (width) =>
    res = null
    switch
      when width <= @meta.maxSmall then res = @.meta.NS+'-small'
      when width <= @meta.maxMiddle then res = @.meta.NS+'-middle'

    res
  
  ###*
  #
  # @method _isInView
  # @private
  # @return {Boolean}
  #
  # culcilates if the row is in view
  ###
  _isInView: =>

    Row.isRowInView @rowData, @meta, @rowMeta

  @isRowInView: (rowData, meta, rowMeta) ->
    if meta.ieVer == 8 then return true
    k = meta.kVisible

    elemTop = rowData.top -  rowMeta.scrollTop + meta.root.offset().top
    elemBottom = elemTop + rowData.height

    k = k or 1

    elemTop <= meta.winHeight * (k + 1) and elemBottom + meta.winHeight * k >= 0
    
    
  ###*
  #
  # @method _onScroll
  # @private
  #
  # is not used
  #
  ###
  _onScroll: =>

    throttled = _.throttle @_scroll, 100
    $(document).on 'scroll', throttled
    
    return
    
    
  ###*
  #
  # @method _scroll
  # @private
  #
  # is not used
  #
  ###

  _scroll: =>
    @rowMeta.scrollTop = $(document).scrollTop()
    @rowMeta.scrollLeft = $(document).scrollLeft()

    if @_isInView() then @queue.execute _.bind @_showImages, @
    else @_hideImages()
    return
    
  ###*
  #
  # @method _hideImages
  # @private
  #
  # 'hides' items witch are not in view
  #
  ###

  _hideImages: =>
    unless @data[@rowData.images[0]].image then return

    _.each @rowData.images, (item)=>

      image = models[@gridId].data[item].image
      image.remove()
      image = null
      delete models[@gridId].data[item].image
      no
    @rowData.inView = false
    return    
    
  
  ###*
  #
  # @method _showImage
  # @private
  #
  # 'shows' item that is not in view
  # 
  # is not used
  ###
  _showImage: (item)=>
    image = new Img @gridId, item
    $image = image.image
    .appendTo @row
    .css
      'margin-right': @meta.margin + 'px'
      height: @data[item].newHeight + 'px'
      width: @data[item].newWidth + 'px'

    sizeClass = @_getClass(@data[item].newWidth)
    $image.addClass sizeClass if sizeClass?

    $(@meta.NSclass+'fs', $image.get(0)).css
      height: @data[item].newHeight + 'px'
      width: @data[item].newWidth + 'px'


    switch
      when @meta.useCanvas
        drawing =  Drawing.getDrawing @gridId

        tmpImg = $image.find @meta.NSclass+'icon'
        parent = tmpImg.parent().get 0
        tmpImg.remove()
        tmp = new Image()
        $(tmp).one 'load', =>
          drawing.setImage @data[item], tmp, parent
          tmp = null
        tmp.src = @data[item].src

    models[@gridId].data[item].image = $image
    return
    
  ###*
  #
  # @method _showImages
  # @private
  #
  # 'shows' items witch are not in view
  # 
  # is not used
  ###
  _showImages: =>

    if @rowData.inView then return

    _.each @rowData.images, (item)=>
      @_showImage(item)
      return


    @rowData.inView = true
    return


###*
#
# @class MMG.View.Image
#
# is used to create a markup for the item
###
class MMG.View.Image

  Models = MMG.Data.Models
  Template = MMG.View.Template
  
  ###*
  #
  # @constructor
  # @param {String} gridId
  # @param {Integer} itemId
  #
  ###

  constructor: (@gridId, @itemId) ->

    @model = Models[@gridId]
    @data = @model.data[@itemId]
    @type = @data.type
    @meta = @model.meta

    @_string = ''
    @image = null

    @_useTemplate()
    @_createImage()
    @_registerImage()
    
  ###*
  #
  # @method _useTemplate
  # @private
  #
  # builds a string from the template
  ###

  _useTemplate: =>
    
    templateName = @meta.templateName
    templateName = @type if @type
    
    compiled = Template.getTemplate(@gridId, templateName).getCompiled()
    @_string = compiled {meta: @meta, data: @data, imageId: @itemId}

    return
    
  ###*
  #
  # @method _createImage
  # @private
  #
  # creates a markup
  ###
  _createImage: =>
    @image = $ @_string
    return

  ###*
  #
  # @method _registerImage
  # @private
  #
  ###
  _registerImage: =>
    @data.image = @image
    return
      
      
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


###*
#
# @class MMG.Utility.ImageLoader
#
###


class MMG.Utility.ImageLoader

  self = @

  ###*
  #
  # @method loadPics
  # @public
  # @static
  # @return {jQuery.Defered}
  #
  # loads images
  #
  ###
  @loadPics:  () ->

    loaded = $.Deferred()
    data = @data
    loader = @meta.loader
    loader.refresh()
    loader.loading = data?.length
    loader.rate = 5

    t = @ # MMG.Data.Core instance

    if data.length == 0
      loader.rate = 100
      loader.end = true
      loaded.resolve()
      return loaded
    
    loads = _.map data, (element, i) ->

      src = element.src

      image = new Image()

      imageLoaded = $.Deferred()

      $(image).one 'load', -> 

        w = data[i].width =$(@).naturalWidth()
        h = data[i].height = $(@).naturalHeight()
        data[i].ratio = w / h
        
        loader.loaded++
        loader.rate = 5 + Math.ceil(loader.loaded / loader.loading * 95) unless loader.loading == 0
        imageLoaded.resolve()
        return
      
      image.src = data[i].src = self._replaceForRetina.call t, src
      
      _.delay ( -> 
        unless image.complete
          image.src = ''
          imageLoaded.resolve()
        return
        
      ), t.model.meta.maxWait
      
      imageLoaded

    $.when.apply null, loads
    .done ->
      loader.end = true
      loaded.resolve()
      return

    loaded

  ###*
  #
  # @method _replaceForRetina
  # @private
  # @static
  # @param {String} src
  #
  # inserts Retina suffix if necessary
  #
  ###
  @_replaceForRetina: (src) ->
    meta = @model.meta
    
    if meta.retina != 2 or meta.pixelRatio < 1.5
      return src
    if src.indexOf(meta.retinaSuffix + '.') >= 0
      return src
    match = src.match(meta.regexMatch)

    replaceSuffix = meta.retinaSuffix + match[0]
    src.replace meta.regexMatch, replaceSuffix
###*
#
# @class MMG.View.View
#
###


class MMG.View.View

  models = MMG.Data.Models
  Img = MMG.View.Image
  Row = MMG.View.Row
  rows = MMG.Data.Rows
  Drawing = MMG.Drawing.Drawing
  DrawingSVG = MMG.Drawing.DrawingSVG
  Queue = MMG.Utility.QueueSingleton
  QueueSimple = MMG.Utility.QueueSimple
  
  ###*
  #
  # @constructor
  # @param {String} gridId
  #
  ###
  constructor: (@gridId) ->

    @model = models[@gridId]
    @data = @model.data
    @meta = @model.meta

    @queue = Queue.getQueue(@gridId)
    @queueSimple = QueueSimple.getQueue(@gridId)

    @_registerRows()
    @_setMeta()

    @_buildView()
    @_setEvents()
    
  ###*
  #
  # @method _registerRows
  # @private
  #
  ###

  _registerRows: =>

    rows[@gridId] =
      data: []
      meta: {}
      built: $.Deferred()

    @rowMeta = rows[@gridId].meta
    @rowData = rows[@gridId].data
    
    return
    
  ###*
  #
  # @method _setMeta
  # @private
  #
  ###
  _setMeta: =>
    meta = {}

    meta.scrollTop = $(document).scrollTop()
    meta.scrollLeft = $(document).scrollLeft()

    rows[@gridId].meta = meta
    return
    
  ###*
  #
  # @method _appendImage
  # @private
  # @param {MMG.View.Row} row
  # @param {Integer} i
  # @param {Object} item
  #
  ###
  _appendImage: (row, i, item) =>

    image = new Img @gridId, i
    image.image
    .appendTo row.row
    .css 'margin-right': @meta.margin + 'px'

    row.registerImage(i)
    row.calculate(item)
    return
    
    
  ###*
  #
  # @method _needNewRow
  # @private
  # @param {MMG.View.Row} row
  # @return {Boolean}
  ###
  _needNewRow: (row)->

    return on unless row
    row.needNew()
    
  ###*
  #
  # @method _setMinHeight
  # @private
  # @param {Object} data 
  #
  # 
  ###

  _setMinHeight: (data) =>

    @meta.minHeight = _.min _.pluck data, 'height'

    @meta.minHeight = @meta.minHeight / 2 if @meta.retina == 1 or
    (@meta.retina == 2 and @meta.pixelRatio > 1.5)
 
    @meta.minHeight = @meta.rowHeight if @meta.rowHeight and
    @meta.rowHeight < @meta.minHeight
    return
    
  ###*
  #
  # @method _buildView
  # @private
  # @param {Integer} index
  #
  # appends new rows into the grid
  ###
  _buildView: (index) =>
    fragment = $(document.createDocumentFragment())
    needNewRow = on
    row = null
    root = @meta.root

    unless index?
      data = @data
      index = 0
    else data = @data.slice index
    @_setMinHeight(data)

    _.reduce data, (memo, item, i, list) ->

      if @_needNewRow(row)

        row.resize() if row?
        row = new Row @gridId

        row.row.appendTo memo

      @_appendImage row, i + index, item

      if list.length == i + 1
        row.rowData.finished = no
        row.resize()

      memo

    , fragment, @
    
    @meta.root.trigger 'dataLoaded',
      all: @data
      
    self = @
    
    ###
    if some filters specified:
    ###
    switch
      when @meta.useCanvas

        _.each data, (item, i) ->
          if item.image
            tmpImg = item.image.find self.meta.NSclass+'icon'
            self.queueSimple.execute _.bind (grid, tmp) ->
              new Drawing grid, tmp
              return
            , self, self.gridId, tmpImg.get 0
            
          return

      when @meta.SVGFilter

        _.each data, (item, i) ->
          if item.image
            tmpImg = item.image.find self.meta.NSclass+'icon'
            parent = tmpImg.parent().get 0
            tmpImg.remove() unless self.meta.twin
            self.queueSimple.execute _.bind (grid, i, p) ->
              new DrawingSVG grid, i, p
              return
            , self, self.gridId, item, parent
            
          return

      when @meta.ieFilter

        _.each data, (item, i) ->
          if item.image
            if self.meta.twin
              twin = $("<img src='"+item.src+"' class='"+self.meta.NS+"-filtered'>")
              $(self.meta.NSclass+'icon', item.image.get(0)).after twin
              twin.css
                height: item.newHeight + 'px'
                width: item.newWidth + 'px'
            else
              $(self.meta.NSclass+'icon', item.image.get(0)).addClass self.meta.NS+'-filtered'
          return
          
      when @meta.forcedTwin
        _.each data, (item, i) ->
          if item.image
            twin = $("<img src='"+item.src+"' class='"+self.meta.NS+"-filtered'>")
            $(self.meta.NSclass+'icon', item.image.get(0)).after twin
            twin.css
              height: item.newHeight + 'px'
              width: item.newWidth + 'px'
          return

    root.width(root.width()-1) #for iOS
    root.append fragment
    .css visibility: 'visible'
    root.width(root.width()+1) #for iOS to repaint the screen
    @meta.root.trigger 'afterLoad',
      all: @data
      
      
    @meta.root.height 'auto'
    return
    
    
    
  ###*
  #
  # @method add
  # @public
  # @param {Object} data
  #
  # adds new rows
  #
  ###

  add: (data) =>

    row = _.last rows[@gridId].data

    startIndex = @data.length

    unless @data.length == 0 or row.finished

      startIndex = row.images[0]
      self = @

      row.row.remove()
      rows[@gridId].data.pop()

    models[@gridId].data = @data = @data.concat(data)
    models[@gridId].meta = @meta

    @_buildView startIndex
    return

  ###*
  #
  # @method _setEvents
  # @private
  #
  ###
  _setEvents: =>
    $(window).resize @_resize

    if @meta.isMobile
      $(document).on 'scroll', @_scroll
    else $(document).on 'scrollstop', @_scroll
    
    return

  ###*
  #
  # @method _resize
  # @private
  #
  ###
  _resize: =>
    w = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
    if (Math.abs w - @meta.winWidth) < 12 then return
    @meta.root.empty()

    @meta.winWidth = w
    @meta.winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight

    @meta.root.width 'auto'

    @_registerRows()
    @_buildView()
    
    return
    
  ###*
  #
  # @method _scroll
  # @private
  #
  ###
  _scroll: =>

    if @meta.scrollStop then return
    top = $(document).scrollTop()
    shift = @rowMeta.scrollTop - top

    if  Math.abs(shift) < @meta.winHeight / @meta.scrollDelta then return

    @rowMeta.scrollTop = top
    @rowMeta.scrollLeft = $(document).scrollLeft()

    @meta.scrollStop = true

    _.each @rowData, (item, i)=>

      if Row.isRowInView item, @meta, @rowMeta
        @_showImages item

      else @_hideImages item
      return
    @meta.scrollStop = false
    return

  ###*
  #
  # @method _hideImages
  # @private
  # @param {MMG.View.Row} row
  #
  # hides rows witch are not in view
  ###
  _hideImages: (row)=>

    unless row.inView then return
    _.each row.images, (item)=>

      image = models[@gridId].data[item].image
      image?.remove()
      image = null

      delete models[@gridId].data[item].image
      no
    row.inView = false
    return

  ###*
  #
  # @method _showImages
  # @private
  # @param {MMG.View.Row} row
  #
  # show rows witch are in view
  ###
  _showImages: (row)=>

    if row.inView then return
    row.inView = true
    _.each row.images, (item)=>
      @queue.execute [_.bind(@_showImage, @, item, row), row]
      return
    return

  ###*
  #
  # @method _showImage
  # @private
  # @param {MMG.View.Row} row
  #
  # show rows that is in view
  ###
  _showImage: (item, row)=>

    image = new Img @gridId, item
    $image = image.image
    .appendTo row.row
    .css
      'margin-right': @meta.margin + 'px'
      height: @data[item].newHeight + 'px'
      width: @data[item].newWidth + 'px'

    sizeClass = @_getClass(@data[item].newWidth)
    $image.addClass sizeClass if sizeClass?

    $(@meta.NSclass+'fs', $image.get(0)).css
      height: @data[item].newHeight + 'px'
      width: @data[item].newWidth + 'px'

    switch
      when @meta.useCanvas
        tmpImg = $image.find @meta.NSclass+'icon'
        new Drawing @gridId, tmpImg.get 0

      when @meta.SVGFilter

        tmpImg = $image.find @meta.NSclass+'icon'
        parent = tmpImg.parent().get 0
        tmpImg.remove() unless @meta.twin

        drawing = new DrawingSVG @gridId, @data[item], parent

      when @meta.ieFilter

        if @meta.twin
          twin = $("<img src='"+@data[item].src+"' class='"+@meta.NS+"-filtered'>")
          $(@meta.NSclass+'icon', $image.get(0)).after twin
          twin.css
            height: @data[item].newHeight + 'px'
            width: @data[item].newWidth + 'px'
        else
          $(@meta.NSclass+'icon', $image.get(0)).addClass @meta.NS+'-filtered'
          
      when @meta.forcedTwin
        twin = $("<img src='"+@data[item].src+"' class='"+@meta.NS+"-filtered'>")
        $(@meta.NSclass+'icon', $image.get(0)).after twin
        twin.css
          height: @data[item].newHeight + 'px'
          width: @data[item].newWidth + 'px'


    models[@gridId].data[item].image = $image
    return
    
  ###*
  #
  # @method _getClass
  # @private
  # @param {Integer} width
  #
  # specifies a 'size class': 
  # 'mmg-small' or 'mmg-middle' or undefined
  ###
  _getClass: (width) =>
    res = null
    switch
      when width <= @meta.maxSmall then res = @.meta.NS+'-small'
      when width <= @meta.maxMiddle then res = @.meta.NS+'-middle'

    res

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



###*
#
# the set of default options
#
###

MMG.Grid.def =
  onInitCallback: ()->
  afterInitCallback: ()->
  onAjaxCallback: ()->
  afterAjaxCallback: ()->
  insertInImgBeforeCallback: ()->
  insertInImgCallback: ()->
  NS: 'mmg'
  NSclass:'.mmg-'
  NSevent: '.mmg'
  regexMatch: /\.[\w\?=]+$/
  retinaSuffix: '@2x'
  margin: 2
  retina: 0
  maxWait: 5000
  maxSmall: 180
  maxMiddle: 400
  useCanvas: false
  pixelRatio: 1
  filters: null
  SVGFilter: false
  kVisible: 3
  scrollDelta: 1.1
  stop: false
  scrollStop: false
  waitCount: 0
  isMobile: false
  rowWidth: 0
  elementsArray: []
  top: 0
  supportSVGFilters: true
  rowsTop: []
  onViewRowsLength: 0
  lightbox: {}
  oldIEFilter: 'none'

###*
#
# MMG.Lightbox.setSwipe
#
# @param {String} name - the name of the swipe presetting
# @container {HTML element} - the container of the swipe
# @data {Array} - the data object
# @options {Object} - user settings
#
# a factory fanction
#
# @return {MMG.Lightbox.Swipe}
#
#
###
MMG.Lightbox.setSwipe = (name, container, data, options) ->


  ###
  vertical
  ###
    
  swipeVertical = (container, data, options) ->
  
    dimentions = ->
      $container = $ @container
        
      winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
      winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight
      
      $container.width winWidth
      .height winHeight
      .addClass 'swipe-vertical'

      $root = $container.children '.swipe-container'
      $swipe = $root.children '.swipe'
      $left = $root.children '.swipe-left-controlls'
      $right = $root.children '.swipe-right-controlls'
      
      $swipe.width winWidth - $right.width() - $left.width()
      $swipe.height winHeight
      $right.height winHeight
      $left.height winHeight
      return
  
    defaults = 

      swipeTemplate: "<div class='swipe-container'><div class='swipe-indicator-container'></div><div class='swipe-left-controlls'><div class='swipe-title-container'><div class='swipe-title'></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-right-controlls'><div class='swipe-ui hidden'><div class='swipe-close'><span class='swipe-icon-cross'></span></div><div class='swipe-buttons'><div class='swipe-left'><span class='swipe-icon-left'></span></div><div class='swipe-show swipe-play'><span></span></div><div class='swipe-right'><span class='swipe-icon-right'></span></div></div></div></div></div>"
      
      onMadeSwipe: dimentions
      
      parser: (data) ->
        _.map data, (item) ->
          href: item.href
          title: item.lb?.title or item.title
       
      onResize: dimentions
      
      makeUI: ->
        that = this
        $ this.container
        .find '.swipe-right'
        .on 'click', (event) =>
          event.stopPropagation()
          this.next()
        
        $ this.container
        .find('.swipe-left').on 'click', (event) =>
          event.stopPropagation()
          this.prev()
          
          
        $ this.container
        .find('.swipe-play').on 'click', (event) =>
          event.stopPropagation()
          this.toggle()
          
        $ this.container
        .find('.swipe-close').on 'click',(event) =>
          event.stopPropagation()
          this.close()
        
        return

      makeContent: ->
        item = this.data[this.index]
        $container = $ this.container
        
        fr = document.createDocumentFragment()
        if item.title
          for char in item.title.split ''
            $ "<div>#{char}</div>"
            .appendTo fr
        
        
        $title = $container
        .find '.swipe-title-container'
        .css
          height: item.height
          width: '100%'
          top: item.top
          left: item.left
        .removeClass 'hidden'
        .children '.swipe-title'
        .empty()
        .append fr
        
        $container
        .find '.swipe-ui'
        .css
          height: item.height
          width: '100%'
          top: item.top
          right: item.left
        .removeClass 'hidden'
       
        return
        
      onClose: ->
        $container = $ this.container
        
        $container
        .find '.swipe-title-container'
        .addClass 'hidden'
        
        $container.find '.swipe-ui'
        .addClass 'hidden'
        
        $container
        .find '.swipe-indicator-container'
        .css 'visibility', 'hidden'
        .empty()
        
        return
        
      beforeSlide: ->
        $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden')
        return
      marginH: 0
      marginV: 3
      indicator: true
      indicatorStart: ->
        $indicator = $('<div class="swipe-indicator"><div></div></div>')
        
        $img = $ @getCurrentSlide()
        .find '.swipe-center'
        
        rect = $img[0].getBoundingClientRect()

        $container = $ this.container
        .find '.swipe-indicator-container'
        .css 
          visibility: 'visible'
          width: rect.width
          top: rect.top
          left: rect.left
          
        $indicator.appendTo $container
        .children 'div'
        .width $(window).width()
        .height $indicator.height()
        
        that = this;
        setTimeout ( ->
          $indicator.css
            'animation-name': 'indicator'
            '-webkit-animation-name': 'indicator'
            'animation-duration': that.delay + 'ms'
            '-webkit-animation-duration': that.delay + 'ms'
          return

        ), 0
        return

      indicatorStop: ->
        $ this.container
        .find '.swipe-indicator-container'
        .css 'visibility', 'hidden'
        .empty()
        return

    settings = $.extend defaults, options

    new MMG.Lightbox.Swipe container, data, settings
  
  ###
  classica
  ###
  swipeClassica = (container, data, options) ->
  
    dimentions = ->
      $container = $ @container
        
      winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
      winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight
      
      $container.width winWidth
      .height winHeight
      .addClass 'swipe-classica'

      $root = $container.children '.swipe-container'
      $swipe = $root.children '.swipe'
      $top = $root.children '.swipe-top-controlls'
      $bottom = $root.children '.swipe-bottom-controlls'
      
      $swipe.height winHeight - $top.height() - $bottom.height()
      $swipe.width winWidth
      return
  
    defaults = 

      swipeTemplate: "<div class='swipe-container'><div class='swipe-indicator-container'></div><div class='swipe-top-controlls'><div class='swipe-title-container'><div class='swipe-title'></div><div class='swipe-close'><span class='swipe-icon-cross'></span></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-bottom-controlls'><div class='swipe-ui hidden'><div class='swipe-left'><span class='swipe-icon-left'></span></div><div class='swipe-show swipe-play'><span></span></div><div class='swipe-right'><span class='swipe-icon-right'></span></div><div class='swipe-counter'></div></div></div></div>"
      
      onMadeSwipe: dimentions
      
      parser: (data) ->

        _.map data, (item) ->
          href: item.href
          title: item.lb?.title or item.title
       
      onResize: dimentions
      
      makeUI: ->
        that = this
        $ this.container
        .find('.swipe-right').on 'click', (event) =>
          event.stopPropagation()
          this.next()
        
        $ this.container
        .find('.swipe-left').on 'click', (event) =>
          event.stopPropagation()
          this.prev()
          
          
        $ this.container
        .find('.swipe-play').on 'click', (event) =>
          event.stopPropagation()
          this.toggle()
          
        $ this.container
        .find('.swipe-close').on 'click',(event) =>
          event.stopPropagation()
          this.close()
        
        return

      makeContent: ->
        $container = $ this.container
        $title = $container.find '.swipe-title-container'
        
        item = this.data[this.index]

        $title
        .width item.width
        .removeClass 'hidden'
        .children '.swipe-title'
        .html item.title

        $container.find('.swipe-ui').width item.width
        .removeClass 'hidden'
        $container.find('.swipe-counter').html this.index + 1 + ' / ' + this.length
        

      onClose: ->
        $container = $ this.container
        
        $container
        .find '.swipe-title-container'
        .addClass 'hidden'
        
        $container.find '.swipe-ui'
        .addClass 'hidden'
        
        $container
        .find '.swipe-indicator-container'
        .css 'visibility', 'hidden'
        .empty()
        
        return
        
      beforeSlide: ->
        $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden')
        return

      indicator: true
      indicatorStart: ->
        $indicator = $('<div class="swipe-indicator"><div></div></div>')
        
        $img = $ @getCurrentSlide()
        .find '.swipe-center'
        
        rect = $img[0].getBoundingClientRect()

        $container = $ this.container
        .find '.swipe-indicator-container'
        .css 
          visibility: 'visible'
          width: rect.width
          top: rect.top
          left: rect.left
          
        $indicator.appendTo $container
        .children 'div'
        .width $(window).width()
        .height $indicator.height()
        
        that = this;
        setTimeout ( ->
          $indicator.css
            'animation-name': 'indicator'
            '-webkit-animation-name': 'indicator'
            'animation-duration': that.delay + 'ms'
            '-webkit-animation-duration': that.delay + 'ms'
          return

        ), 0
        return

      indicatorStop: ->
        $ this.container
        .find '.swipe-indicator-container'
        .css 'visibility', 'hidden'
        .empty()
        return

    settings = $.extend defaults, options

    new MMG.Lightbox.Swipe container, data, settings
    
    
  ###
  untitled
  ###
  swipeUntitled = (container, data, options) ->
  
    dimentions = ->
      $container = $ @container
        
      winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
      winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight
      
      $container.width winWidth
      .height winHeight
      .addClass 'swipe-classica'

      $root = $container.children '.swipe-container'
      $swipe = $root.children '.swipe'
      $top = $root.children '.swipe-top-controlls'
      $bottom = $root.children '.swipe-bottom-controlls'
      
      $swipe.height winHeight - $top.height() - $bottom.height()
      $swipe.width winWidth
      return
  
    defaults = 

      swipeTemplate: "<div class='swipe-container'><div class='swipe-indicator-container'></div><div class='swipe-top-controlls'><div class='swipe-title-container'><div class='swipe-close'><span class='swipe-icon-cross'></span></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-bottom-controlls'><div class='swipe-ui hidden'><div class='swipe-left'><span class='swipe-icon-left'></span></div><div class='swipe-show swipe-play'><span></span></div><div class='swipe-right'><span class='swipe-icon-right'></span></div><div class='swipe-counter'></div></div></div></div>"
      
      onMadeSwipe: dimentions
      
      parser: (data) ->
       _.map data, (item) ->
         href: item.href
         title: item.lb?.title or item.title
         description: item.lb?.description or item.description
         
       
      onResize: dimentions
      
      makeUI: ->
        that = this
        $ this.container
        .find('.swipe-right').on 'click', (event) =>
          event.stopPropagation()
          this.next()
        
        $ this.container
        .find('.swipe-left').on 'click', (event) =>
          event.stopPropagation()
          this.prev()
          
          
        $ this.container
        .find('.swipe-play').on 'click', (event) =>
          event.stopPropagation()
          this.toggle()
          
        $ this.container
        .find('.swipe-close').on 'click',(event) =>
          event.stopPropagation()
          this.close()
        
        return

      makeContent: ->
        $container = $ this.container
        $title = $container.find '.swipe-title-container'
        
        item = this.data[this.index]

        $title
        .width item.width
        .removeClass 'hidden'
        

        $container.find('.swipe-ui').width item.width
        .removeClass 'hidden'
        $container.find('.swipe-counter').html this.index + 1 + ' / ' + this.length
        

      onClose: ->
        $container = $ this.container
        
        $container
        .find '.swipe-title-container'
        .addClass 'hidden'
        
        $container.find '.swipe-ui'
        .addClass 'hidden'
        
        $container
        .find '.swipe-indicator-container'
        .css 'visibility', 'hidden'
        .empty()
        
        return
        
      beforeSlide: ->
        $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden')
        return

      indicator: true
      indicatorStart: ->
        $indicator = $('<div class="swipe-indicator"><div></div></div>')
        
        $img = $ @getCurrentSlide()
        .find '.swipe-center'
        
        rect = $img[0].getBoundingClientRect()

        $container = $ this.container
        .find '.swipe-indicator-container'
        .css 
          visibility: 'visible'
          width: rect.width
          top: rect.top
          left: rect.left
          
        $indicator.appendTo $container
        .children 'div'
        .width $(window).width()
        .height $indicator.height()
        
        that = this;
        setTimeout ( ->
          $indicator.css
            'animation-name': 'indicator'
            '-webkit-animation-name': 'indicator'
            'animation-duration': that.delay + 'ms'
            '-webkit-animation-duration': that.delay + 'ms'
          return

        ), 0
        return

      indicatorStop: ->
        $ this.container
        .find '.swipe-indicator-container'
        .css 'visibility', 'hidden'
        .empty()
        return

    settings = $.extend defaults, options

    new MMG.Lightbox.Swipe container, data, settings
    
  ###
  minimal
  ###
  swipeMinimal = (container, data, options) ->
  
    dimentions = ->
      $container = $ @container
        
      winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
      winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight
      
      $container.width winWidth
      .height winHeight
      .addClass 'swipe-classica'

      $root = $container.children '.swipe-container'
      $swipe = $root.children '.swipe'
      $top = $root.children '.swipe-top-controlls'
      $bottom = $root.children '.swipe-bottom-controlls'
      
      $swipe.height winHeight - $top.height() - $bottom.height()
      $swipe.width winWidth
      return
      
    defaults = 

      swipeTemplate: "<div class='swipe-container'><div class='swipe-top-controlls'><div class='swipe-title-container'><div class='swipe-title'></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-bottom-controlls'><div class='swipe-ui hidden'><div class='swipe-counter'></div></div></div></div></div>"
      
      onMadeSwipe: dimentions
      
      parser: (data) ->
       _.map data, (item) ->
         href: item.href
         title: item.lb?.title or item.title
       
      onResize: dimentions
      
      indicator: false
      
      onClose: ->
        $container = $ this.container
        
        $container
        .find '.swipe-title-container'
        .addClass 'hidden'
        
        $container.find '.swipe-ui'
        .addClass 'hidden'
        
        return
        
      beforeSlide: ->
        $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden')
        return
        
      makeContent: ->
        $container = $ this.container
        $title = $container.find '.swipe-title-container'
        
        item = this.data[this.index]

        $title
        .width item.width
        .removeClass 'hidden'
        .children '.swipe-title'
        .html item.title

        $container.find('.swipe-ui').width item.width
        .removeClass 'hidden'
        $container.find('.swipe-counter').html this.index + 1 + ' / ' + this.length
        return
      
    settings = $.extend defaults, options

    new MMG.Lightbox.Swipe container, data, settings
  
  ###
  simple
  ###
  swipeSimple = (container, data, options) ->
  
    dimentions = ->
      $container = $ @container
        
      winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
      winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight
      
      $container.width winWidth
      .height winHeight
      .addClass 'swipe-simple'
      return
      
    defaults = 

      onMadeSwipe: dimentions
      
      parser: (data) ->
       _.map data, (item) ->
         href: item.href
         title: item.lb?.title or item.title
       
      onResize: dimentions
      
      indicator: false
      marginH: 3
      marginV: 3
      
    settings = $.extend defaults, options

    new MMG.Lightbox.Swipe container, data, settings
    
  if _.isFunction name then name container, data, options
  else
    switch name

      when 'classica'
        swipeClassica container, data, options

      when 'untitled'
        swipeUntitled container, data, options

      when 'minimal'
        swipeMinimal container, data, options

      when 'simple'
        swipeSimple container, data, options

      when 'vertical'
        swipeVertical container, data, options

      else swipeClassica container, data, options
      
###*
#
# @class MMG.Lightbox.LightboxSwipe
#
###

class MMG.Lightbox.Swipe

  ###*
  #
  # @constructor
  # @container {HTML element} - the container of the swipe
  # @data {Array} - the data object
  # @options {Object} - user settings
  #
  ###
  
  constructor: (@container,  data,  options = {}) ->
  
    @_setNaturalSize()
    
    @parser = options.parser || @_identity
    
    @data = @_parseData data
    
    @_init options
    
    
    
    
  ###*
  #
  # @method _noop
  # @private
  #
  ###
  _noop: () ->
  
  
  ###*
  #
  # @method _identity
  # @param {Any} v 
  # @return {Any}
  # @private
  #
  ###
  _identity: (v) -> v
  
  ###*
  #
  # @method _offloadFn
  # @param {Function} fn - the function that must be executed
  # @private
  #
  ###
  _offloadFn: (fn) ->
    setTimeout fn or @_noop, 0
    return
  
  ###*
  #
  # @method _parseData
  # @private
  # @param {Array} data - the data object
  #
  ###
  _parseData: (data) ->
  
    @parser data
  
  ###*
  #
  # @method _init
  # @private
  # @param {Object} options
  #
  ###
  _init: (options) ->
    
    unless @container
      throw new Error 'You must define a container element'
    @browser = 
      addEventListener: !!window.addEventListener
      touch: 'ontouchstart' of window
      transitions: ((temp) ->
        props = [
          'transitionProperty'
          'WebkitTransition'
          'MozTransition'
          'OTransition'
          'msTransition'
        ]
        for i of props
          if temp.style[props[i]] != undefined
            return true
        false
      )(document.createElement('swipe'))
    
    @index = parseInt(options.startSlide, 10) or 0
    @speed = options.speed or 400
    @continuous = if options.continuous != undefined then options.continuous else true
    @transitionEnd = options.transitionEnd
    @delay = 0
    @indicator = options.indicator or false
    @showDelay = options.delay or 4000
    @auto = options.auto
    @delay = @showDelay if @auto
    @stopPropagation = options.stopPropagation
    @disableScroll = options.disableScroll
    @closeOnEnd = options.closeOnEnd
    @enableClick = options.enableClick
    @enableClick ?= true
    @enableWheel = options.enableWheel
    @enableWheel ?= true
    @swipeClass = options.swipeClass or 'swipe'
    @swipeWrapClass = options.swipeWrapClass or 'swipe-wrap'
    @slideClass = options.slideClass or 'slide'
    @playClass = options.playClass or 'swipe-play'
    @stopClass = options.stopClass or 'swipe-stop'
    @firstClass = options.firstClass or 'swipe-first-slide'
    @lastClass = options.lastClass or 'swipe-last-slide'
    @captionClass = options.captionClass or 'mmg-lb-caption'
    @lightbox = options.lightbox or {}
    @ieVer = @lightbox.ieVer
    @interval = null
    @makeUI = options.makeUI or @_noop
    @onResize = options.onResize
    @makeContent = options.makeContent
    @onMadeSwipe = options.onMadeSwipe
    @delayedSetup = options.delayedSetup
    @beforeSlide = options.beforeSlide
    @close = options.close or @_noop
    @close = _.wrap @close, (func) =>
      @stop()
      func()
      return
      
    @onClose = options.onClose or @_noop
    @indicatorStart = options.indicatorStart
    @indicatorStop = options.indicatorStop
    @loaderTemplate = options.loaderTemplate or '<div class="loader"><span class="l1"></span><span class="l2"></span><span class="l3"></span></div>'
    
    @resizable = on
    if options.resizable != undefined
      @resizable = options.resizable

    @swipeTemplate = options.swipeTemplate
    @swipeTemplate ?= "<div class='#{@swipeClass}'><div class='#{@swipeWrapClass}'></div></div>"
    
    @useCaptionTemplate = options.useCaptionTemplate
    
    @captionName = options.captionName
    @getCaptionName = options.getCaptionName
    @captionHideAfter = options.captionHideAfter
    @loadingClass = options.loadingClass or 'loading'
    
    @marginH = options.marginH || 5
    @marginV = options.marginV || 0
    
    @type = 'image'
    @images = []
    @_makeSwipe()

    unless @delayedSetup
      @_setup()
    @_makeUI()
    
    $(@container).on 'click', @_onClick if @enableClick
    @_getWheel @container  if @enableWheel
    
    return
    
  ###*
  #
  # @method _setup
  # @private
  #
  #
  ###  
  _setup:  ->
  
    @_removeAll()
    @delay = @showDelay if @auto
    @element = $ @root 
    .children '.' + @swipeWrapClass
    .get 0
    
    @slides = @_makeSlides()
        
    @length = @slides.length;
    
    @indicatorRun = false;
    
    @images =(0 for i in @slides)
    
    @start = {}
    @delta = {}
    @isScrolling = undefined
    
    @continuous = no if @length < 2
    
    if @browser.transitions and @continuous and @length < 3
      @element.appendChild @slides[0].cloneNode(true)
      @element.appendChild @element.children[1].cloneNode(true)
      @slides = @element.children
      
    @slidePos = []
    
    @width = @root.getBoundingClientRect().width || @root.offsetWidth
    
    @element.style.width = (@length * @width) + 'px'
    
    
    _.each @slides, (slide, pos) =>
    
      slide.style.width = @width + 'px'
      slide.setAttribute('data-index', pos)
      
      if @browser.transitions
        slide.style.left = pos * -@width + 'px'
        @_move(pos, (if @index > pos then -@width else if @index < pos then @width else 0), 0)
      return
      
    if @continuous and @browser.transitions
      @_move @_circle(@index - 1), -@width, 0
      @_move @_circle(@index + 1), @width, 0
      
    unless @browser.transitions
      @element.style.left = @index * -@width + 'px'
      
    @root.style.visibility = 'visible'
    
    @_loadImages(@index)
    
  
    @_addListeners()
    $('body').on 'keydown', @_onkeydown
    
    return
  
  ###*
  #
  # @method _resize
  # @param {Boolean} active
  # @private
  #
  ###
  _resize: (active = on) =>
    @onResize?.call @
    @_setup() if active
    return
    
  ###*
  #
  # @method _onMadeSwipe
  # @private
  #
  ###  
  _onMadeSwipe: () ->
  
    @onMadeSwipe?.call @
    return
    
  ###*
  #
  # @method _makeSwipe
  # @private
  #
  ###   
  _makeSwipe: () ->
    
    $swipe = $ @swipeTemplate
    $swipe.appendTo $ @container
    @_onMadeSwipe()
    
    if $swipe.hasClass @swipeClass then @root = $swipe.get 0
    
    else 
      @root = $swipe.find '.' + @swipeClass
      .get 0

    return
    
  ###*
  #
  # @method _makeContent
  # @private
  #
  ###  
  _makeContent: () ->
    @_addClasses()
    
    clearTimeout @hide
    @_makeInterval()
    @makeContent?.call @
    @_showCaptions()
    return
    
  ###*
  #
  # @method _makeUI
  # @private
  #
  ###  
  _makeUI: () ->
    @makeUI.call @  
    return
    
  ###*
  #
  # @method _removeAll
  # @private
  #
  ###    
  _removeAll: ->

    $(@root).off()
    $(@element).empty().off()
    
    $('body').off 'keydown', @_onkeydown
    
    return
    
  ###*
  #
  # @method _makeSlides
  # @private
  # @return {Array of HTML-elements}
  #
  ###  
  _makeSlides: ->
    
    @_makeSlide item for item in @data
    
  
  ###*
  #
  # @method _makeSlide
  # @private
  # @param {Object} item
  # @return {HTML-element}
  #
  ###    
  _makeSlide:(item) ->
    
    $ '<div class="slide"></div>'
    .appendTo $ @element
    .get 0
  
  ###*
  #
  # @method _isLegalIndex
  # @private
  # @param {Integer} index
  # @return {Boolean}
  #
  ###
  _isLegalIndex: (index) ->
    last = @length - 1
    diff = index - @index

    if -3 <  diff < 3 then return on
    
    unless @continuous then return no
    
    if last - diff + 1 < 3 then return on
    if last + diff + 1 < 3 then return on
    
    no
  
  ###*
  #
  # @method _unloadImages
  # @private
  #
  ###
  _unloadImages: ->
    @_unloadImage i for i in [0 .. @data.length - 1]
    return
    
  ###*
  #
  # @method _unloadImage
  # @private
  # @param {Integer} index
  #
  ###  
  _unloadImage: (index) ->
    if @_isLegalIndex index then return
    unless @images[index] then return
    
    $(@slides[index]).empty()
    @images[index] = no
    return
  
  ###*
  #
  # @method _loadSlide
  # @param {Integer} index
  # @private
  #
  #
  ###
  _loadSlide: (index) ->
  
    type = @data[index].type || @type
    
    switch type
      when 'image' then @_loadImage index
      
    return
  
  
  ###*
  #
  # @method _makeLoader
  # @private
  # @return {jQuery Object}
  #
  ###
  _makeLoader: ->
    
    $ @loaderTemplate
  
  
  ###*
  #
  # @method _loadingStart
  # @private
  # @param {Integer} index
  #
  ###
  _loadingStart: (index) ->
  
    $(@slides[index]).addClass @loadingClass
    @_makeLoader().appendTo @slides[index]
    return
    
  ###*
  #
  # @method _loadingStop
  # @private
  # @param {Integer} index
  #
  ###  
  _loadingStop: (index) ->
    
    $(@slides[index]).removeClass @loadingClass
    .empty()
    return
  
  ###*
  #
  # @method _loadError
  # @private
  # @param {Integer} index
  #
  ### 
  _loadError: (index) ->
  
    console.log event.currentTarget.src + " can't be loaded"
    return
    
  ###*
  #
  # @method _loadImage
  # @private
  # @param {Integer} index
  #
  ###   
  _loadImage: (index) ->
    
    self = @
    
    unless @_isLegalIndex index then return
    if @images[index] > 0 then return
    
    @images[index] = 1
    
    @_loadingStart index
    
    img = new Image()
    root = @root
    data = @data
    slides = @slides
    
    winHeight = $(root).height()
    winWidth = $(root).width()
    
    
    bigWidth = winWidth * (1 - (@marginH / 50))
    bigHeight = winHeight * (1 - (@marginV / 50))
    winRatio = bigWidth / bigHeight
    
    $(img).on 'error', (event) ->

      self.images[index] = 2
      
      self._loadingStop index
      self._loadError index
      
      return 
      
    $(img).on 'load', () ->
    
      self.images[index] = 3
      w = $(@).naturalWidth()
      h = $(@).naturalHeight()
      
      newHeight = h
      newWidth = w
      ratio = w / h

      if ratio > winRatio
        if w > bigWidth
          newWidth = bigWidth
          newHeight = newWidth / ratio
      else
        if h > bigHeight
          newHeight = bigHeight
          newWidth = newHeight * ratio
          
      newHeight = Math.round newHeight
      newWidth = Math.round newWidth
      
      self._loadingStop index
      
      left = Math.round (winWidth - newWidth)/2
      top =  Math.round (winHeight - newHeight)/2
      
      
      caption = self.useCaptionTemplate(self.data, self.captionName, index)
      
    
      $ img
      .wrap '<div class="swipe-center"></div>'
      .parent()
      .append caption
      .css 
        left: left
        top: top
        width: newWidth
        height: newHeight
      .appendTo slides[index]
      
      
      data[index].width = newWidth
      data[index].height = newHeight
      data[index].top = top
      data[index].left = left

      if index == self.index
        $(self.root).trigger 'loadend'
        self._makeContent() 
      
      return
      
    img.src = data[index].href
    return
  
  ###*
  #
  # @method _loadImages
  # @private
  #
  ###  
  _loadImages:  ->
  
    @_loadSlide @index
    @_loadSlide @index + 1 if @index + 1 < @length
    @_loadSlide @index - 1 if @index - 1 >= 0
    
    @_loadSlide i for i in [@data.length - 1 .. 0]
    return
    
  ###*
  #
  # @method _addListeners
  # @private
  #
  ###    
  _addListeners: ->
    if @browser.addEventListener

      if @browser.touch
        @element.addEventListener 'touchstart', @, false
      if @browser.transitions
        @element.addEventListener 'webkitTransitionEnd', @, false
        @element.addEventListener 'msTransitionEnd', @, false
        @element.addEventListener 'oTransitionEnd', @, false
        @element.addEventListener 'otransitionend', @, false
        @element.addEventListener 'transitionend', @, false
        @element.addEventListener 'mousedown', @, false
        @element.addEventListener 'mousemove', @, false
        @element.addEventListener 'mouseup', @, false
        @element.addEventListener 'mouseout', @, false
        
    return
    
  ###*
  #
  # @method _prev
  # @private
  #
  ###
  _prev: =>
  
    if @continuous
      @_slide @index - 1
    else if @index
      @_slide @index - 1
      
    return
    
  ###*
  #
  # @method _next
  # @private
  #
  ###  
  _next: =>
    @indicatorStop?.call @ if @indicator and @indicatorRun
    @indicatorRun = false
    
    if @continuous
      @_slide @index + 1
    else if @index < @length - 1
      @_slide @index + 1
      
    return
  
  ###*
  #
  # @method _circle
  # @param  {Integer} index
  # @return {Integer}
  # @private
  #
  ###
  _circle: (index) ->
    
    (@length + (index % @length)) % @length
  
  ###*
  #
  # @method _slide
  # @param  {Integer} to
  # @param {Integer} slideSpeed
  # @private
  #
  ###
  _slide: (to, slideSpeed) ->
  
    if @index == to then return
    
    if @browser.transitions
      direction = Math.abs(@index - to) / (@index - to)
      
      if @continuous
        natural_direction = direction
        direction = -@slidePos[@_circle(to)] / @width
        
        if direction != natural_direction
          to = -direction * @length + to
        
      diff = Math.abs(@index - to) - 1
      while diff--
        @_move @_circle((if to > @index then to else @index) - diff - 1), @width * direction, 0
        
      to = @_circle to

      @_move @index, @width * direction, slideSpeed || @speed
      @_move to, 0, slideSpeed || @speed

      if @continuous 
        @_move(@_circle(to - direction), -(@width * direction), 0)
        
    else
      to = @_circle to
      @_animate(@index * -@width, to * -@width, slideSpeed or @speed)
      
    @_changeIndex to
    
    return
  
  ###*
  #
  # @method _move
  # @param  {Integer} index
  # @param {Integer} dist
  # @param {Integer} speed
  # @private
  #
  ###
  _move: (index, dist, speed) ->
    @_translate(index, dist, speed);
    @slidePos[index] = dist;
    
    return
  
  ###*
  #
  # @method _translate
  # @param  {Integer} index
  # @param {Integer} dist
  # @param {Integer} speed
  # @private
  #
  ###
  _translate: (index, dist, speed) ->
  
    slide = @slides[index]
    
    style = slide?.style
    
    unless style then return
    
    style.webkitTransitionDuration =
    style.MozTransitionDuration =
    style.msTransitionDuration =
    style.OTransitionDuration =
    style.transitionDuration = speed + 'ms'
    
    style.webkitTransform = 'translate(' + dist + 'px,0)' + 'translateZ(0)'
    style.msTransform =
    style.MozTransform =
    style.OTransform = 'translateX(' + dist + 'px)'
    return
    
  ###*
  #
  # @method _animate
  # @param  {Integer} from
  # @param {Integer} to
  # @param {Integer} speed
  # @private
  #
  ###  
  _animate: (from, to, speed) ->
  
    unless speed
      @element.style.left = to + 'px'
      return
    start = +new Date
    
    timer = setInterval((=>
      timeElap = +new Date - start
      if timeElap > speed
        @element.style.left = to + 'px'
        if @delay
          @_begin()
          
        @transitionEnd?.call(event, @index, @slides[@index])
        @_makeContent()
        
        $(@root).trigger 'slidemoveend',
          slide: @slides[@index]
          data: @data[@index]
          index: @index
          
        @_loadImages()
        @_unloadImages()
        clearInterval timer
        return
      @element.style.left = (to - from) * Math.floor(timeElap / speed * 100) / 100 + from + 'px'
      return
    ), 4)
    return
  
  ###*
  #
  # @method handleEvent
  # @param {Event} event
  # @public
  #
  ###
  handleEvent: (event) ->
    switch event.type
      when 'mousedown'
        @_onmousedown event
      when 'mousemove'
        @_onmousemove event
      when 'mouseup'
        @_onmouseup event
      when 'mouseout'
        @_onmouseout event
      when 'touchstart'
        @_startHandler event
      when 'touchmove'
        @_moveHandler event
      when 'touchend'
        @_offloadFn @_endHandler(event)
      when 'webkitTransitionEnd', 'msTransitionEnd', 'oTransitionEnd', 'otransitionend', 'transitionend'
        @_offloadFn @_transitionEndHandler(event)

    if @stopPropagation then event.stopPropagation()
    return
    
  ###*
  #
  # @method _onmousedown
  # @param {Event} event
  # @private
  #
  ###  
  _onmousedown:(event) ->
    event.preventDefault()
    (event.originalEvent || event).touches = [
      pageX: event.pageX
      pageY: event.pageY
    ]
    @_startHandler event
    return

  ###*
  #
  # @method _onmousemove
  # @param {Event} event
  # @private
  #
  ### 
  _onmousemove: (event) ->
    if @start and @start.time
      (event.originalEvent || event).touches = [
        pageX: event.pageX
        pageY: event.pageY
      ]
      @_moveHandler event
    return

  ###*
  #
  # @method _onmouseup
  # @param {Event} event
  # @private
  #
  ### 
  _onmouseup: (event) ->
    if @start
      @_endHandler event
      delete @start
    return
    
  ###*
  #
  # @method _onmouseout
  # @param {Event} event
  # @private
  #
  ###    
  _onmouseout: (event) ->
    if @start
      target = event.target
      related = event.relatedTarget
      if !related or (related != target and !$.contains(target, related))
        @_onmouseup event
    return
    
  ###*
  #
  # @method _onkeydown
  # @param {Event} event
  # @private
  #
  ###      
  _onkeydown: (event) =>
    
    switch event.which || event.keyCode
      when 37 then @prev()
      when 39 then @next()
      
    return
  
  ###*
  #
  # @method _startHandler
  # @param {Event} event
  # @private
  #
  ### 
  _startHandler: (event) ->
    touches = event.touches[0]

    @start =
      x: touches.pageX
      y: touches.pageY
      time: +new Date

    @isScrolling = undefined
    @delta = {}

    @element.addEventListener 'touchmove', @, false
    @element.addEventListener 'touchend', @, false

    return
  
  ###*
  #
  # @method _moveHandler
  # @param {Event} event
  # @private
  #
  ### 
  _moveHandler: (event) ->

    if event.touches.length > 1 || event.scale && event.scale != 1 then return

    if @disableScroll then event.preventDefault()

    touches = event.touches[0]

    @delta =
      x: touches.pageX - (@start.x)
      y: touches.pageY - (@start.y)

    if typeof isScrolling == 'undefined'
      @isScrolling = !!(@isScrolling or Math.abs(@delta.x) < Math.abs(@delta.y))

    unless @isScrolling
      event.preventDefault()

      @stop()

      if @continuous

        @_translate @_circle(@index - 1), @delta.x + @slidePos[@_circle(@index - 1)], 0

        @_translate @index, @delta.x + @slidePos[@index], 0

        @_translate @_circle(@index + 1), @delta.x + @slidePos[@_circle(@index + 1)], 0

      else
        @delta.x = @delta.x / (if !@index and @delta.x > 0 or @index == @length - 1 and @delta.x < 0 then Math.abs(@delta.x) / @width + 1 else 1)

        @_translate @index - 1, @delta.x + @slidePos[@index - 1], 0

        @_translate @index, @delta.x + @slidePos[@index], 0

        @_translate @index + 1, @delta.x + @slidePos[@index + 1], 0


    return
  
  ###*
  #
  # @method _changeIndex
  # @param {Integer} newIndex
  # @private
  #
  ###
  _changeIndex: (newIndex) ->
    @index = newIndex
    @beforeSlide?.call @
    return
    
  ###*
  #
  # @method _endHandler
  # @param {Event} event
  # @private
  #
  ### 
  _endHandler: (event) ->

    duration = +new Date - @start.time

    isValidSlide = Number(duration) < 250 and
    Math.abs(@delta.x) > 20 or
    Math.abs(@delta.x) > @width / 2

    isPastBounds =  !@index && @delta.x > 0 or
    @index == @slides.length - 1 && @delta.x < 0

    if @continuous then isPastBounds = no

    direction = @delta.x < 0

    unless @isScrolling
      if isValidSlide and !isPastBounds
        if direction
          if @continuous
            @_move @_circle(@index-1), -@width, 0
            @_move @_circle(@index+2), @width, 0
          else @_move @index-1, -@width, 0

          @_move @index, @slidePos[@index] - @width, @speed

          @_move @_circle(@index + 1), @slidePos[@_circle(@index + 1)] - @width, @speed

          @_changeIndex @_circle(@index + 1)

        else
          if @continuous
            @_move @_circle(@index + 1), @width, 0

            @_move @_circle(@index - 2), -@width, 0

          else @_move @index+1, @width, 0

          @_move @index, @slidePos[@index] + @width, @speed

          @_move @_circle(@index - 1), @slidePos[@_circle(@index - 1)] + @width, @speed

          @_changeIndex @_circle(@index - 1)

      else

        if @continuous
          @_move @_circle(@index - 1), -@width, @speed

          @_move @index, 0, @speed

          @_move @_circle(@index + 1), @width, @speed

        else
          @_move @index - 1, -@width, @speed
          @_move @index, 0, @speed
          @_move @index + 1, @width, @speed
    @element.removeEventListener('touchmove', @, false)
    @element.removeEventListener('touchend', @, false)
    return
    
  ###*
  #
  # @method _transitionEndHandler
  # @param {Event} event
  # @private
  #
  ### 
  _transitionEndHandler: (event) ->
    if parseInt(event.target.getAttribute('data-index'), 10) == @index
      if @delay
        @_begin()
      @transitionEnd?.call event, @index, @slides[@index]
      @_makeContent()
      $(@root).trigger 'slidemoveend',
        slide: @slides[@index]
        data: @data[@index]
        index: @index
      
      @_loadImages()
      @_unloadImages()

    return
    
  ###*
  #
  # @method _onClick
  # @param {Event} event
  # @private
  #
  ###   
  _onClick: (event) =>
    if @delta and (Math.abs(this.delta.x) > 20 or Math.abs(this.delta.y) > 20)
      delete @delta
      return

    if $(event.target).is('img') or $(event.target).hasClass @captionClass
      @next()
    else @close()
    
    return
  
  ###*
  #
  # @method _begin
  # @private
  #
  ###   
  _begin: ->
    if !@continuous and @isLast()
      if @closeOnEnd
        @interval = setTimeout @close, @delay
        @indicatorStart?.call @
        @indicatorRun = true if @indicatorStart
      else @stop()
    else
      @interval = setTimeout @_next, @delay
      if @indicator
        @indicatorStart?.call @
        @indicatorRun = true if @indicatorStart
    
    return
  
  ###*
  #
  # @method _stop
  # @private
  #
  ### 
  _stop: ->
    @delay = 0
    clearTimeout @interval
    return
    
  ###*
  #
  # @method _setNaturalSize
  # @private
  #
  ###   
  _setNaturalSize: ->

      (($) ->

        props = [
          'Width'
          'Height'
        ]
        prop = undefined

        setProp = (natural, prop) ->
          $.fn[natural] = if natural of new Image then (->
            @[0][natural]
          ) else (->
            node = @[0]
            img = undefined
            value = undefined
            if node.tagName.toLowerCase() == 'img'
              img = new Image
              img.src = node.src
              value = img[prop]
            value
          )
          return

        while prop = props.pop()
          setProp 'natural' + prop, prop.toLowerCase()
        return
      ) jQuery
      return
    
  
  ###*
  #
  # @method setup
  # @public
  #
  ###
  setup: ->
    @_setup()
    return
  
  ###*
  #
  # @method go
  # @public
  # @param {Integer} to
  # @param {Integer} speed
  #
  ###
  go: (to, speed) =>
    @stop()
    @_slide to, speed
    return
  
  ###*
  #
  # @method first
  # @public
  #
  ###
  first: =>
    @stop()
    @_slide 0, @speed / 2
    return
    
  ###*
  #
  # @method last
  # @public
  #
  ###  
  last: =>
    @stop()
    @_slide @length - 1, @speed / 2
    return
    
  ###*
  #
  # @method prev
  # @public
  #
  ###  
  prev: =>
    @stop()
    @_prev()
    return
    
  ###*
  #
  # @method next
  # @public
  #
  ###  
  next: =>
    @stop()
    @_next()
    return
    
  
  ###*
  #
  # @method getPos
  # @public
  # @return {Integer} - current index
  #
  ###  
  getPos: ->
    @index
  
  ###*
  #
  # @method getRoot
  # @public
  # @return {HTML-element} - the root element of the Swipe
  #
  ###
  getRoot: ->
    @root
    
  ###*
  #
  # @method getNumSlides
  # @public
  # @return {Integer} - the number of slides
  #
  ###  
  getNumSlides: ->
    @length
  
  ###*
  #
  # @method getStatus
  # @public
  # @return {Integer} - 0, 1, 2, 3
  #
  ### 
  getStatus: ->
    @images[@index]
  
  ###*
  #
  # @method getCurrentSlide
  # @public
  # @return {HTML-element}
  #
  ###
  getCurrentSlide: ->
    @slides[@index]
  
  ###*
  #
  # @method getCurrentTitle
  # @public
  # @return {String}
  #
  ###
  getCurrentTitle: ->
    @data[@index].title
  
  ###*
  #
  # @method getCurrentTitle
  # @public
  # @return {String}
  #
  ###
  getCurrentType: ->
    @data[@index].type
  
  ###*
  #
  # @method play
  # @public
  #
  ###
  play: =>
    @delay = @showDelay
    @_begin()
    button = $(@container).find '.' + @playClass

    if button
      button.removeClass @playClass
      .addClass @stopClass
    return
    
  ###*
  #
  # @method stop
  # @public
  #
  ###  
  stop: =>
    @_stop()
    @indicatorStop?.call @ if @indicator and @indicatorRun
    @indicatorRun = false
    button = $(@container).find '.' + @stopClass
    if button
      button.removeClass @stopClass
      .addClass @playClass
    return  
  
  ###*
  #
  # @method toggle
  # @public
  #
  ###  
  toggle: =>
    if @delay 
      @stop()
      
    else 
      @play()
    return
  
  ###*
  #
  # @method getRect
  # @public
  # @return {Object}
  #
  ###
  getRect: =>
    @root.getBoundingClientRect()
  
  ###*
  #
  # @method getMargins
  # @public
  # @return {Object}
  #
  ###
  getMargins: =>
    V: @marginV
    H: @marginH
     
  ###*
  #
  # @method setData
  # @public
  # @param {Array} data
  #
  ###  
  setData: (data) ->
    @data = @_parseData data
    return
  
  ###*
  #
  # @method setIndex
  # @public
  # @param {Integer} index
  #
  ### 
  setIndex: (index) ->
    @index = index * 1
    return
  
  ###*
  #
  # @method resize
  # @public
  # @param {Boolean} active
  #
  ### 
  resize: (active) ->
    @_resize active
    return
    
  _getWheel: (elem) ->

    _onWheel = (e) =>
      e = e or window.event
      
      delta = e.deltaY or e.detail or -e.wheelDelta
      if delta > 0
        @next() if @element.children

      else if delta < 0
        @prev() if @element.children

      if e.preventDefault then e.preventDefault() else (e.returnValue = false)
      return
      
    onWheel = _.throttle _onWheel, 200
    
    if elem.addEventListener
      if 'onwheel' of document
        elem.addEventListener 'wheel', onWheel, false
      else if 'onmousewheel' of document
        elem.addEventListener 'mousewheel', onWheel, false
      else
        elem.addEventListener 'MozMousePixelScroll', onWheel, false
    else
      elem.attachEvent 'onmousewheel', onWheel
    return
  
  ###*
  #
  # @method isLast
  # @public
  # @return {Boolean}
  #
  ### 
  isLast: ->
    unless @continuous
      @index == @length - 1
    else no
  
  ###*
  #
  # @method isFirst
  # @public
  # @return {Boolean}
  #
  ### 
  isFirst: ->
    unless @continuous
      @index == 0
    else no
  
  ###*
  #
  # @method _addClasses
  # @private
  #
  ### 
  _addClasses: ->

    if @continuous then return
    
    $container = $ @container
    if @isLast()
      $container.addClass @lastClass
      .removeClass @firstClass
    else if @isFirst()
      $container.removeClass @lastClass
      .addClass @firstClass
    else 
      $container.removeClass @lastClass
      .removeClass @firstClass
      
    return
    
  _makeInterval: ->
    if @captionHideAfter
      @hide = setTimeout @_hideAfter, @captionHideAfter
    return
    
  _hideAfter: =>
    $caption = $ @slides[@index]
    .find '.mmg-lb-caption'
    unless  0 < @ieVer < 10
      $caption.removeClass 'mmg-lb-show'
    @lightbox.root?.trigger 'timeForCaptionHide', $caption.get 0
    
    return
    
  _showCaptions: =>
  
    $container = $ @container
    $caption = $ @slides[@index]
    .find '.mmg-lb-caption'
    
    unless 0 < @ieVer < 10
      $container.find '.mmg-lb-show'
      .removeClass 'mmg-lb-show'

      setTimeout (->$caption.addClass 'mmg-lb-show'), 0
    
    @lightbox.root?.trigger 'timeForCaption', $caption.get 0
    
    return
    
###*
#
# @class MMG.Lightbox.LightboxSwipe
#
###

class MMG.Lightbox.LightboxSwipe

  Template = MMG.View.Template
  ###*
  #
  # @constructor
  # @param {String} gridId
  # @param {Object} options
  #
  ###
  constructor: (@gridId, @meta)->

    @vendorPrefix = '-webkit-'
    @isRetina = false
    @pixelRatio = 1
    @regexMatch = /\.[\w\?=]+$/
    @retinaSuffix = '@2x'
    @count = 0
    @NS = 'mmg'
    @options = @meta.lightbox
    
    @isActive = no
    @current_index = 0
    @_init()

  ###*
  #
  # @method _init
  # @private
  #
  ###
  _init: ->
    warning = 'options parameter must be of an Object type!'

    if @options == undefined
      alert warning
    else if typeof @options == 'string'
      grid = @options
    else if typeof @options == 'object'
      grid = @options.grid
      if @options.retinaSuffix
        @retinaSuffix = @options.retinaSuffix
      @pixelRatio = window.devicePixelRatio
      if @options.retina
        @isRetina = @options.retina
      if @options.ns
        @NS = options.ns + '-'
      @NSclass = '.' + @NS + '-'
      
      if @options.name
        @name= @options.name
      @captionHideAfter = @options.captionHideAfter
      if @options.swipe
      
        @isSwipe = on
        
        if _.isObject @options.swipe
          @swipeOptions = @options.swipe
          
        else @swipeOptions = {}
        
        @swipeName = @swipeOptions.name or 'classica'
        
    else
      alert warning

    @root = $ grid
    @ieVer = @_ieVer()
    @loaderTemplate = $('<div id=\'' + @NS + '-viewer-loader\'><span class=\'l1\'></span><span class=\'l2\'></span><span class=\'l3\'></span></div>')
    @_makeLightBox()
    
    @bodyhtml = $ 'html, body'
    @body = $ 'body'
    @html = $ 'html'
    @bodyOverflowX = @body.css 'overflow-x'
    @bodyOverflowY = @body.css 'overflow-y'
    @htmlOverflowX = @html.css 'overflow-x'
    @htmlOverflowY = @html.css 'overflow-y'
    
    $(window).resize @_onResize
    @_setWin()

    return
  
  
  ###*
  #
  # @method _setWin
  # @private
  #
  ###
  _setWin: ->
  
    winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
    winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight

    @container.css
      width: winWidth
      height: winHeight

    return
    
  ###*
  #
  # @method setData
  # @public
  #
  # Adds data to the swipe instance
  #
  ###  
  setData: (data) ->
    @data = data
    if @isSwipe and @swipe
      @swipe.setData data
    return
  
  
  ###*
  #
  # @method show
  # @public
  # @param {Integer} index
  #
  ###  
  show: (index)=>
    @_setWin()
    if @ieVer > 0 && @ieVer < 10
      @_show_ie9 index
    else  @_show index
    
    return
  
    
  ###*
  #
  # @method _setAnimationName
  # @private
  #
  # specifies the animation name for the 'click' event
  #
  ###
  _setAnimationName: =>
    @count++
    @NS + '-lightbox-' + @gridId + '-' + @count
    
  ###*
  #
  # @method _replaceForRetina
  # @private
  # @static
  # @param {String} src
  #
  # inserts Retina suffix if necessary
  #
  ###
  _replaceForRetina: (src) =>
    if !@isRetina or @pixelRatio == 1
      return src
    if src.indexOf(@retinaSuffix) >= 0
      return src
    match = src.match(@regexMatch)
    replaceSuffix = @retinaSuffix + match[0]
    src.replace @regexMatch, replaceSuffix
    
    
  ###*
  #
  # @method _setStylesheet
  # @private
  # @param {String} styleString
  # @param {String} Class
  #
  ###

  _setStylesheet: (styleString, Class) =>
    $('<style>',
      class: @NS + '-' + Class
      type: 'text/css')
    .text(styleString)
    .appendTo 'head'
    return
    
  ###*
  #
  # @method _removeStylesheet
  # @private
  # @param {String} Class
  #
  ###  
  _removeStylesheet: (Class) =>
    style = @NS+'-'+Class

    $("head>style.#{style}").remove()
    return
    
    
  ###*
  #
  # @method _setVendorPrefix
  # @private
  #
  ###
  _setVendorPrefix: =>
    if 'animation' of @container.get(0).style
      @vendorPrefix = ''
    return
    
    
  ###*
  #
  # @method _hide
  # @private
  # @param {Event} e
  # 
  # closes the Lightbox
  ###
  _hide:  =>

    unless @isActive then return
    
    @isActive = no
    self = @
    @loader?.remove()
    @bg.removeClass 'mmg-on'
   
    setTimeout ->   
      self.container
      .css 
        visibility: 'hidden'
        display: 'none'
      return
    , 400

    @imageBlock.empty()
    .removeAttr 'style'
    .removeClass @NS + '-animate'

    @image = null
    @imageBlock.off()
    @_removeStylesheet 'lightbox-animation'
    @swipe._removeAll()
    
    @body.css
      'overflow-x': @bodyOverflowX
      'overflow-y': @bodyOverflowY
      
    @html.css
      'overflow-x': @htmlOverflowX
      'overflow-y': @htmlOverflowY

    return


  ###*
  #
  # @method _onResize
  # @private
  #
  ###
  _onResize: =>
    @_setWin()
    @swipe?.resize @isActive

    return
  
  
  ###*
  #
  # @method _show
  # @private
  # opens the Lightbox with css animation
  ###
  _show: (index) =>
  
    @isActive = on
    self = @
    
    @bodyhtml.css
      'overflow-x': 'hidden'
      'overflow-y': 'hidden'
    
    onAnimationEnd = (event) ->
      
      self.swipe.setIndex index
      self.swipe.setup()
      $ self.swipe.getRoot()
      .one 'loadend', ->
        self.imageBlock
        .empty()
        .removeAttr 'style'
        .css
          visibility: 'hidden'
        .removeClass self.NS + '-animate'
        
        self.swipe.play() if self.swipe.delay

        return
          
      $(this).off 'oanimationend MSAnimationEnd webkitAnimationEnd animationend'
      return

    @container
    .css 
      display: 'block'
      visibility: 'visible'

    setTimeout ->
      self.bg.addClass 'mmg-on';
    , 50


    winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
    winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight

    href = @data[index].href

    href = @_replaceForRetina href

    @current_index = index
    @image = @data[index].image

    rect = @swipe.getRect()
    margins = @swipe.getMargins()
    
    box = @image.get(0).getBoundingClientRect()
    top = box.top
    left = box.left
    width = box.right - left
    height = box.bottom - top
    bigWidth = rect.width * (1 - (margins.H / 50))
    bigHeight = rect.height  * (1 - (margins.V / 50))
    bigTop = rect.top
    bigLeft = rect.left

    @loader = @loaderTemplate.clone()
    .css
      top: height / 2 - 8
      left: width / 2 - 40

    @imageBlock
      .css
        width: width
        height: height
        top: top
        left: left
      .append(@loader)

    $ '<img>'
    .appendTo @imageBlock
    .one 'load', ->
      self.loader.remove()
      $(this).addClass self.NS + '-visible'

      slideWidth = this.naturalWidth
      slideHeight = this.naturalHeight
      ratio = slideWidth / slideHeight
      winRatio = bigWidth / bigHeight

      newHeight = slideHeight
      newWidth = slideWidth

      if ratio > winRatio
        if slideWidth > bigWidth
          newWidth = bigWidth 
          bigLeft ?= rect.width * margins.H / 100
          newHeight = newWidth / ratio
      else
        if slideHeight > bigHeight
          newHeight = bigHeight  
          bigTop ?= rect.height * margins.V / 100
          newWidth = newHeight * ratio
          
      newHeight = Math.round newHeight
      newWidth = Math.round newWidth
      bigTop = Math.round bigTop
      bigLeft = Math.round bigLeft
          

      initialX = (width - newWidth) / 2
      initialY = (height - newHeight) / 2
      finalX = (width - newWidth) / 2 + (rect.width / 2) - (left + (width / 2)) + bigLeft 
      finalY = (height - newHeight) / 2 +
      (rect.height / 2) - (top + (height / 2)) + bigTop
      scale = "scale3d(#{width / newWidth}, #{height / newHeight}, 1)"
      
      initialX = Math.round initialX
      initialY = Math.round initialY
      
      finalX = Math.round finalX
      finalY = Math.round finalY
      
      self.imageBlock.css
        width: newWidth
        height: newHeight
        '-webkit-transform': "translate3d(#{initialX}px,#{initialY}px, 0) " + scale
        transform: "translate3d(#{initialX}px,#{initialY}px, 0) " + scale

      name = self._setAnimationName()

      style = '@' + self.vendorPrefix + 'keyframes ' + name + ' {' +
      '0% {' +
      self.vendorPrefix + 'transform: translate3d(' + initialX + 'px,' + initialY + 'px, 0) ' + scale +
      '}' +
      ' 40% {' +
      self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) ' + scale +
      ' }' +
      '100% {' +
      self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) scale3d(1,1,1)' +
      '}' +
      '}'


      self._setStylesheet style, 'lightbox-animation'

      self.imageBlock.css self.vendorPrefix + 'animation-name', name

      .addClass self.NS + '-animate'

      .one 'oanimationend MSAnimationEnd webkitAnimationEnd animationend', onAnimationEnd

      $(this).off 'load'
      return

    .attr 'src', href

    return

  ###*
  #
  # @method _show_ie9
  # @private
  # opens the Lightbox with jQuery animation
  # for ie8 and ie9
  #
  ###
  _show_ie9: (index) =>
  
    @isActive = on
    @container.css
      display: 'block'
      visibility: 'visible'
    @bg.stop true
    .css opacity: 0
    .animate
      opacity: 0.9, 1000
    @swipe.setIndex index
    @swipe.setup()
    $ @swipe.getRoot()
      .one 'loadend', =>
        @swipe.play() if @swipe.delay
        return
    
    return

  ###*
  #
  # @method _makeLightBox
  # @private
  # creates the markup
  #
  ###
  _makeLightBox: =>
    @container = $('<div></div>', class: @NS + '-lb', id: @NS + '-lb-' + @gridId.substr(6))
    .css display: 'none'
    .appendTo('body')
    @imageBlock = $('<div></div>', class: @NS + '-center').appendTo @container
    @swipeContainer = $('<div></div>', class: @NS + '-swipe-container').appendTo @container
    @bg = $('<div></div>', class: @NS + '-lb-bg').appendTo @container
    
    @container.on 'click touchend escape.mmg', (e) =>
      if @isSwipe and  e.type != 'escape' then return
      @swipe.close()
      return
    self = @
    
    $(document).on 'keydown', (e) ->
      if e.which == 27 then self.container.trigger('escape.mmg')
      return
    
    @_setVendorPrefix()

    @container.addClass @NS+'-ie9' if @ieVer == 9
    @container.addClass @NS+'-ie8' if @ieVer == 8
    
    devices = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
    if devices.test navigator.userAgent
      @container.addClass @NS+'-lb-mb'
      
    swipeOptions =  
      delayedSetup: on
      resizable: no
      close: @close
      captionName: @name
      lightbox: @meta
      captionHideAfter: @captionHideAfter
      useCaptionTemplate: _.partial @useCaptionTemplate, @meta, @gridId
    settings = _.extend @swipeOptions, swipeOptions
    @swipe = MMG.Lightbox.setSwipe @swipeName, @swipeContainer.get(0), @data, settings
    
    return

  ###*
  #
  # @method _ieVer
  # @private
  #
  ###
  _ieVer: ->
    ver = 0
    switch
      when document.all && !document.querySelector then ver = 7
      when document.all && !document.addEventListener then ver = 8
      when document.all && !window.atob then ver = 9
      when document.all then ver = 10
    ver
  
  ###*
  #
  # @method close
  # @public
  #
  ###
  close: =>
    @swipe?.onClose()
    @_hide()
    return
    
  useCaptionTemplate: (meta, gridId, data, name, index)->
    unless name then return no
    
    compiled = MMG.View.Template.getTemplate(gridId, name, 'l').getCompiled()
    
    compiled {meta: meta, data: data[index]}
###*
#
# @class class MMG.Lightbox.Lightbox
#
###

class MMG.Lightbox.Lightbox

  Template = MMG.View.Template
  ###*
  #
  # @constructor
  # @param {String} gridId
  # @options {Object}
  #
  ###
  constructor: (@gridId, @meta)->

    @vendorPrefix = '-webkit-'
    @isRetina = false
    @isSimpleClick = true
    @pixelRatio = 1
    @regexMatch = /\.[\w\?=]+$/
    @retinaSuffix = '@2x'
    @count = 0
    @NS = 'mmg'
    @options = @meta.lightbox
    
    @isActive = no
    @current_index = 0
    @_init()

  ###*
  #
  # @method _init
  # @private
  #
  ###
  _init: ->
    warning = 'options parameter must be of an Object type!'

    if @options == undefined
      alert warning
    else if typeof @options == 'string'
      grid = @options
    else if typeof @options == 'object'
      grid = @options.grid
      if @options.retinaSuffix
        @retinaSuffix = @options.retinaSuffix
      @pixelRatio = window.devicePixelRatio
      if @options.retina
        @isRetina = @options.retina
      if @options.ns
        @NS = options.ns + '-'
      @NSclass = '.' + @NS + '-'
      if @options.simpleClick == false
        @isSimpleClick = @options.simpleClick
      if @options.captionHideAfter
        @captionHideAfter = @options.captionHideAfter
      if @options.name
         @name= @options.name
    else
      alert warning

    @root = $ grid
    @ieVer = @_ieVer()
    @loaderTemplate = $('<div id=\'' + @NS + '-viewer-loader\'><span class=\'l1\'></span><span class=\'l2\'></span><span class=\'l3\'></span></div>')
    @_makeLightBox()
#    triggers = $(@NSclass + 'link')
    $(window).resize @_onResize
    @_onResize()

    return
    
  setData: (data) ->
    @data = data
    
  show: (index)=>
    @_onResize()
    if @ieVer > 0 && @ieVer < 10
      @_show_ie9 index
    else  @_show index
    
    
    
  _useCaptionTemplate: ->
  
    unless @name then return no
    
    compiled = Template.getTemplate(@gridId, @name, 'l').getCompiled()
    
    compiled {meta: @meta, data: @data[@current_index]}
    
    
  ###*
  #
  # @method _setAnimationName
  # @private
  #
  # specifies the animation name for the 'click' event
  #
  ###
  _setAnimationName: =>
    @count++
    @NS + '-lightbox-' + @gridId + '-' + @count
    
  ###*
  #
  # @method _replaceForRetina
  # @private
  # @static
  # @param {String} src
  #
  # inserts Retina suffix if necessary
  #
  ###
  _replaceForRetina: (src) =>
    if !@isRetina or @pixelRatio == 1
      return src
    if src.indexOf(@retinaSuffix) >= 0
      return src
    match = src.match(@regexMatch)
    replaceSuffix = @retinaSuffix + match[0]
    src.replace @regexMatch, replaceSuffix
    
    
  ###*
  #
  # @method _setStylesheet
  # @private
  # @param {String} styleString
  # @param {String} Class
  #
  ###

  _setStylesheet: (styleString, Class) =>
    $('<style>',
      class: @NS + '-' + Class
      type: 'text/css')
    .text(styleString)
    .appendTo 'head'
    return
    
  _removeStylesheet: (Class) =>
    style = @NS+'-'+Class

    $("head>style.#{style}").remove()
    return
    
    
  ###*
  #
  # @method _setVendorPrefix
  # @private
  #
  ###
  _setVendorPrefix: =>
    if 'animation' of @container.get(0).style
      @vendorPrefix = ''
    return
    
    
  ###*
  #
  # @method _hide
  # @private
  # @param {Event} e
  # 
  # closes the Lightbox
  ###
  _hide:  =>

    unless @isActive then return
    
    @isActive = no
    self = @
    @loader.remove()
    @bg.removeClass 'mmg-on'
 
    setTimeout ->   
      self.container
      .css 
        visibility: 'hidden'
        display: 'none'
      return
    , 400

    
    @caption?.css 'display', 'none'

    @imageBlock.empty()
    .removeAttr 'style'
    .removeClass @NS + '-animate'

    @caption = null
    @image = null
    @imageBlock.off()
    @_removeStylesheet 'lightbox-animation'
    clearTimeout @captionHide

    return


  ###*
  #
  # @method _onResize
  # @private
  #
  ###
  _onResize: =>

    winHeight = window.innerHeight or screen.height
    winWidth = window.innerWidth or screen.width

    @container.css
      width: winWidth
      height: winHeight

    return
  
  
  ###*
  #
  # @method _show
  # @private
  # opens the Lightbox with css animation
  ###
  _show: (index) =>
    @isActive = on
    self = @
    onAnimationEnd = (event) ->
      if self.caption?.get 0
        self.caption.appendTo($(this)).css display: 'block'
        setTimeout (->
          self.caption.addClass self.NS + '-lb-show'
          self.root.trigger 'timeForCaption', self.caption.get 0
          return
        ), 50
        if self.captionHideAfter
          self.captionHide = setTimeout((->
            self.caption.removeClass self.NS + '-lb-show'
            self.root.trigger 'timeForCaptionHide', self.caption.get 0
            return
          ), self.captionHideAfter)
      $(this).off 'oanimationend MSAnimationEnd webkitAnimationEnd animationend'
      return

    @container
    .css 
      display: 'block'
      visibility: 'visible'

    setTimeout ->
      self.bg.addClass 'mmg-on';
    , 50


    winHeight = window.innerHeight || screen.height
    winWidth = window.innerWidth || screen.width

    href = @data[index].href


    href = @_replaceForRetina href

    
      
    @current_index = index
    @image = @data[index].image

    string = @_useCaptionTemplate()
    
    @caption = $ string if string

    box = @image.get(0).getBoundingClientRect()
    top = box.top
    left = box.left
    width = box.right - left
    height = box.bottom - top
    bigWidth = winWidth * 0.9
    bigHeight = winHeight * 0.9

    @loader = @loaderTemplate.clone()
    .css
      top: height / 2 - 8
      left: width / 2 - 40

    @imageBlock
      .css
        width: width
        height: height
        top: top
        left: left
      .append(@loader)

    $ '<img>'
    .appendTo @imageBlock
    .one 'load', ->
      self.loader.remove()
      $(this).addClass self.NS + '-visible'

      slideWidth = this.naturalWidth
      slideHeight = this.naturalHeight
      ratio = slideWidth / slideHeight
      winRatio = winWidth / winHeight

      newHeight = slideHeight
      newWidth = slideWidth

      if ratio > winRatio
        if slideWidth > bigWidth
          newWidth = bigWidth
          newHeight = newWidth / ratio
      else
        if slideHeight > bigHeight
          newHeight = bigHeight
          newWidth = newHeight * ratio
          
      newHeight = Math.round newHeight
      newWidth = Math.round newWidth
          

      initialX = (width - newWidth) / 2
      initialY = (height - newHeight) / 2
      finalX = (width - newWidth) / 2 + (winWidth / 2) - (left + (width / 2))
      finalY = (height - newHeight) / 2 +
      (winHeight / 2) - (top + (height / 2))
      scale = "scale3d(#{width / newWidth}, #{height / newHeight}, 1)"
      
      finalX = Math.round finalX
      finalY = Math.round finalY
      
      self.imageBlock.css
        width: newWidth
        height: newHeight
        '-webkit-transform': "translate3d(#{initialX}px,#{initialY}px, 0) " + scale
        transform: "translate3d(#{initialX}px,#{initialY}px, 0) " + scale

      name = self._setAnimationName()

      style = '@' + self.vendorPrefix + 'keyframes ' + name + ' {' +
      '0% {' +
      self.vendorPrefix + 'transform: translate3d(' + initialX + 'px,' + initialY + 'px, 0) ' + scale +
      '}' +
      ' 40% {' +
      self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) ' + scale +
      ' }' +
      '100% {' +
      self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) scale3d(1,1,1)' +
      '}' +
      '}'


      self._setStylesheet style, 'lightbox-animation'

      self.imageBlock.css self.vendorPrefix + 'animation-name', name

      .addClass self.NS + '-animate'

      .one 'oanimationend MSAnimationEnd webkitAnimationEnd animationend', onAnimationEnd

      $(this).off 'load'
      return

    .attr 'src', href

    return

  ###*
  #
  # @method _show_ie9
  # @private
  # opens the Lightbox with jQuery animation
  # for ie8 and ie9
  #
  ###
  _show_ie9: (index) =>

    self = @
    @isActive = on

    @container.css
      display: 'block'
      visibility: 'visible'
    @bg.stop true
    .css opacity: 0
    .animate
      opacity: 0.8, 1000

    winHeight = $(window).height()
    winWidth = $(window).width()

    href = @data[index].href


    href = @_replaceForRetina href

    
      
    @current_index = index
    @image = @data[index].image
    
    string = @_useCaptionTemplate()
    @caption = $ string if string
    
    bigWidth = winWidth * 0.9
    bigHeight = winHeight * 0.9

    loaderTemplate = $('<div id=\'' + @NS + '-viewer-loader\'></div>')


    @loader = loaderTemplate.clone()
    .css
      top: winHeight / 2 - 50
      left: winWidth / 2 - 50
      opacity: 0
    .appendTo @container
    .animate opacity: 0.2

    $ '<img>'
    .appendTo @imageBlock
    .one 'load', ->
      self.loader.remove()
      $(this).addClass self.NS + '-visible'

      slideWidth = $(this).naturalWidth()
      slideHeight = $(this).naturalHeight()
      ratio = slideWidth / slideHeight
      winRatio = winWidth / winHeight
      newHeight = slideHeight
      newWidth = slideWidth

      if ratio > winRatio
        if slideWidth > bigWidth
          newWidth = bigWidth
          newHeight = newWidth / ratio
      else
        if slideHeight > bigHeight
          newHeight = bigHeight
          newWidth = newHeight * ratio

      self.imageBlock.css
        width: newWidth
        height: newHeight
        left: (winWidth-newWidth)/2
        top: (winHeight-newHeight)/2
      .stop true
      .delay 200
      .animate
        opacity: 1, 400, 'swing', ->
          unless self.caption then return
          self.root.trigger 'timeForCaption', self.caption.get 0
          if self.captionHideAfter
            self.captionHide = setTimeout((->
              self.root.trigger 'timeForCaptionHide', self.caption.get 0
              return
          ), self.captionHideAfter)

          return

      self.caption?.appendTo self.imageBlock
      .css display: 'block'

      $(this).off 'load'
      return

    .attr 'src', href

    return
  
  ###*
  #
  # @method _makeLightBox
  # @private
  # creates the markup
  #
  ###
  _makeLightBox: =>
    @container = $('<div></div>', class: @NS + '-lb', id: @NS + '-lb-' + @gridId.substr(6))
    .css display: 'none'
    .appendTo('body')
    @imageBlock = $('<div></div>', class: @NS + '-center').appendTo @container
    @bg = $('<div></div>', class: @NS + '-lb-bg').appendTo @container
    
    @container.on 'click touchend escape.mmg', (e) =>
      if !@isSimpleClick and $(e.target).parents(".#{@NS}-center").get(0) != undefined
        return
      @_hide()
      return
    self = @
    
    $(document).on 'keydown', (e) ->
      if e.which == 27 then self.container.trigger('escape.mmg')
      return
    
    @_setVendorPrefix()
    if !@isSimpleClick
      @container.addClass @NS+'-noclick'

    @container.addClass @NS+'-ie9' if @ieVer == 9
    @container.addClass @NS+'-ie8' if @ieVer == 8
    
    devices = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
    if devices.test navigator.userAgent
      @container.addClass @NS+'-lb-mb'
    return

  ###*
  #
  # @method _ieVer
  # @private
  #
  ###
  _ieVer: ->
    ver = 0
    switch
      when document.all && !document.querySelector then ver = 7
      when document.all && !document.addEventListener then ver = 8
      when document.all && !window.atob then ver = 9
      when document.all then ver = 10
    ver
    
  close: =>
    @_hide()


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

      
###*
#
# @class MMG.Utility.NaturalSize
# for old IE when native naturalWidth/naturalHeight
# are undefined
#
# inspired by Jack Moore
# http://www.jacklmoore.com/notes/naturalwidth-and-naturalheight-in-ie/
#
###

class MMG.Utility.NaturalSize
  ###
  # the Singleton Pattern is used
  #
  ###
  instance = null

  ###*
  #
  # @method set
  # @public
  # @static
  #
  ###
  @set: ->

    instance ?= new PrivatClass()

  ###*
  #
  # @class PrivateClass
  # 
  ###
  class PrivatClass

    ###*
    #
    # @constructor
    #
    ###
    constructor: ->

      @setNaturalSize()
      
      
      
    ###*
    #
    # @method setNaturalSize
    # @public
    #
    ###
    setNaturalSize: ->

      (($) ->

        props = [
          'Width'
          'Height'
        ]
        prop = undefined

        setProp = (natural, prop) ->
          $.fn[natural] = if natural of new Image then (->
            @[0][natural]
          ) else (->
            node = @[0]
            img = undefined
            value = undefined
            if node.tagName.toLowerCase() == 'img'
              img = new Image
              img.src = node.src
              value = img[prop]
            value
          )
          return

        while prop = props.pop()
          setProp 'natural' + prop, prop.toLowerCase()
        return
      ) jQuery

###*
#
# @class MMG.Data.ModelBuilder
#
###

class MMG.Data.ModelBuilder


  Models = MMG.Data.Models
  def = MMG.Grid.def
  Data = MMG.Data.Core
  
  ###*
  #
  # @constructor
  # @param {String} gridId
  # @param {Object} options
  #
  ###
  
  constructor: (@gridId, @options) ->

    ###
    # the array of items data:
    ###
    @data = []
    
    ###
    # the object of metadata:
    ###
    @meta = {}

    @_init()

  ###*
  #
  # @method _init
  # @private
  #
  ###
  _init: =>

    @_registerModel()

    @_setMeta()
    @_setTemplate()
    @_setLBTemplate()
    @_setData()
    
    return

  ###*
  #
  # @method _registerModel
  # @private
  #
  ###
  _registerModel: =>

    Models[@gridId] =
      data: []
      meta: {}
      built: $.Deferred()
      
    return

  ###*
  #
  # @method _setMeta
  # @private
  #
  # sets metadata
  ###
  _setMeta: =>
    _o = @options
    warning = 'options parameter must be of a String or of an Object type!'
    
    ###
    # devicePixelRatio
    # calculated by the script
    ###
    @meta.pixelRatio = window.devicePixelRatio
    devices = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Touch/i
    if devices.test navigator.userAgent
      ###
      #
      # is device is mobile
      # calculated by the script
      ###
      @meta.isMobile = true

      if @meta.pixelRatio > 1.5

        @meta.kVisible = 2
        @meta.scrollDelta = 2

      else
        @meta.kVisible = 1
        @meta.scrollDelta = 2

    unless _o?
      alert warning

    else if typeof _o is 'string'
      @meta.grid = _o
      @meta.root = $(@meta.grid)

    else if typeof _o is 'object'
      @meta.grid = _o.grid
      @meta.root = $(@meta.grid)

      if _o.ns
        ###
        # Namespace
        # specified by the user
        # default: 'mmg-'
        ###
        @meta.NS = _o.ns + '-'
        @meta.NSclass = '.' + @meta.NS + '-'
        @meta.NSevent = '.' + @meta.NS

      if _o.data
        ###
        # initial data,
        # specified by the user in the script itself
        ###
        @meta.data = _o.data


      if _o.templateName
        ###
        # the name of the template
        # specified by the user
        # required
        ###
        @meta.templateName = _o.templateName

      if _o.gridClass
        ###
        # the class that is added to the root element
        # specified by the user
        ###
        @meta.gridClass = _o.gridClass

      if _o.mobileGridClass
        ###
        # the class that is added to the root element
        # specified by the user
        # for mobile devices
        ###
        mobileGridClass = _o.mobileGridClass


      if _o.vars 
        ###
        # Pares of keys and values.
        # An object, that contains custom variables
        ###
        @meta.vars = _o.vars

      if _o.url
        ###
        # An Url of JSON file that is used for data loading by AJAX.
        # specified by the user
        ###
        @meta.url = _o.url

      if _o.parser
        ###
        # the function that is used as a parser
        # specified by the user
        ###
        @meta.parser = _o.parser
        
      if _o.jsonParser
        ###
        # if defined it will be used to convert JSON object
        #
        # a function that is used as a parser
        # specified by the user
        ###
        @meta.jsonParser = _o.jsonParser
        

      if _o.margin?
        ###
        # margin-right and margin-bottom css properties
        # for items
        # specified by the user
        # default: 2
        # {Integer or '0'}
        ###
        @meta.margin = _o.margin - 0

      if _o.retina?
        ###
        # 0 - no Retina mode
        # 1,2 - Retina modes
        # specified by the user
        ###
        @meta.retina = _o.retina
        
      if _o.retinaSuffix?
        ###
        # Overrides the default retina suffix ('@2x')
        # specified by the user
        ###
        @meta.retinaSuffix = _o.retinaSuffix

      if _o.height?
        ###
        # the maximum height of a row
        # specified  by the user
        ###
        @meta.rowHeight = _o.height

      if _o.timeout?
        ###
        # the maximum loading time in ms
        # specified  by the user
        # default: 5000
        # {Integer}
        ###
        @meta.maxWait = _o.timeout

      if _o.small?
        ###
        # the maximum width for images witch can classified as 'small'
        # specified  by the user
        # default: 180
        # {Integer}
        ###
        @meta.maxSmall = _o.small

      if _o.middle?
        ###
        # the maximum width for images witch can classified as 'middle'
        # specified  by the user
        # default: 400
        # {Integer}
        ###
        @meta.maxMiddle = _o.middle

      if _o.canvasFilters?
        ###
        # the array of specified canvas filters
        # specified  by the user
        ###
        @meta.filters = _o.canvasFilters

      if _o.twin?
        ###
        # the 'twin' mode
        # default: false
        # {Boolean}
        ###
        @meta.twin = _o.twin

      if _o.svgFiltersId?
        ###
        # the ID of the appropriate SVG-filter
        # specified  by the user
        ###
        @meta.svgFiltersId = _o.svgFiltersId
        
        ###
        # 
        # SVG-Filter usage
        # {Boolean}
        # default: false
        # calculated by the script
        ###
        @meta.SVGFilter = true

      if _o.oldIEFilter?
        ###
        # old-style MS-filter usage
        # for IE8, IE9
        # {Boolean}
        # default: false
        #  specified  by the user
        ###
        @meta.oldIEFilter = _o.oldIEFilter
      
      
      @meta.excludeClass =  'mmg-external'
      
      if _o.excludeClass?
        @meta.excludeClass = _o.excludeClass
        
      if _o.excludable?
        @meta.excludable = _o.excludable
        
      if _o.lightbox == false
        ###
        # 
        # the object of options for the built-in lightbox
        # or false
        # default: {}
        # specified by the user
        ###
        @meta.lightbox = false
        
      else if typeof _o.lightbox == 'object'

        @meta.lightbox = _o.lightbox
        @meta.lightbox.grid = @meta.grid
      
      else
        @meta.lightbox = {}
        @meta.lightbox.grid = @meta.grid

      if _o.canvas != undefined
        if _o.canvas == 1
          ###
          # canvas usage
          # default: false
          # {Boolean}
          # calculated by the script 
          ###
          @meta.useCanvas = true
        else if _o.canvas == 2
          if @meta.isMobile
            @meta.useCanvas = true
          else
            @meta.useCanvas = false
        else
          @meta.useCanvas = false
    else alert warning

    ieVer = @_ieVer()
    ###
    # the version of IE
    # calculated by the script
    ###
    @meta.ieVer  = ieVer

    if @meta.isMobile and @meta.useCanvas and @meta.retina
      @meta.kVisible = 1
    if @meta.isMobile and @meta.filters and @meta.retina
      @meta.kVisible = 1
    if @meta.isMobile and @meta.SVGFilter
      @meta.kVisible = 1

    if @meta.isMobile and mobileGridClass
      @meta.gridClass = mobileGridClass
    ###
    # SVG-filters support
    # {Boolean}
    # calculated by the script
    ###
    @meta.supportSVGFilters =
    window['SVGFEColorMatrixElement']? and
    SVGFEColorMatrixElement.SVG_FECOLORMATRIX_TYPE_SATURATE == 2

    @meta.SVGFilter = false unless @meta.supportSVGFilters
    @meta.ieFilter = false

    if ieVer > 0 && ieVer < 10

      @meta.SVGFilter = false
      switch @meta.oldIEFilter
        when 'none'
          @meta.useCanvas = false
          @meta.twin = false
        when 'canvas'
          if ieVer == 9
            @meta.useCanvas = true
          else
            @meta.ieFilter = true
            @meta.useCanvas = false
        when 'css'
          @meta.ieFilter = true
          @meta.useCanvas = false
        else
          @meta.useCanvas = false
          @meta.twin = false
    else
      if @meta.SVGFilter
        @meta.useCanvas = false
      else if @meta.filters
        @meta.useCanvas = true
      else
        @meta.twin = false
        @meta.forcedTwin = on if _o.forcedTwin
        
    ###
    # the window width and height
    # {Integer}
    # calculated by the script
    ###
    @meta.winWidth = window.innerWidth or document.documentElement.clientWidth or document.body.clientWidth
    @meta.winHeight = window.innerHeight or document.documentElement.clientHeight or document.body.clientHeight

    ###
    # the minumum height of images
    # calculated by the script
    # {Integer}
    # default: Infinity
    ###
    @meta.minHeight = Infinity

    _.defaults(@meta, def)

    Models[@gridId].meta = @meta
    
    
    
    @meta.loader = 
      loading: 0
      loaded: 0
      end: false
      rate: 0
      refresh: ->
        @loading = 0
        @loaded = 0
        @end = false
        @rate = 0
        return
      observer: (f1, f2) ->
        prev = 0
        @refresh()
        
        observe = () =>
        
          if @loaded != prev or @loaded == 0

            f1.call @
            prev = @loaded
            
          unless @end then setTimeout observe, 50
          
          else f2.call @
          
          return
        
        observe()
        return
    
    return

  ###*
  #
  # @method _setData
  # @private
  # @param {String} gridId
  #
  ###
  _setData: =>

    new Data(@gridId)
    
    return

  ###*
  #
  # @method _setTemplate
  # @private
  # sets meta.template and meta.callback
  #
  ###
  _setTemplate: =>
    if @options.templateName
      @meta.templateName = @options.templateName
    else @meta.templateName = 'Simple'

#    @meta.template = MMG.Templates[@meta.templateName].template
#    @meta.callback = MMG.Templates[@meta.templateName].callback
#
#    if @meta.isMobile
#      if MMG.Templates[@meta.templateName].mobile
#        if MMG.Templates[@meta.templateName].mobile.template
#          @meta.template = MMG.Templates[@meta.templateName].mobile.template
#        if MMG.Templates[@meta.templateName].mobile.callback
#          @meta.callback = MMG.Templates[@meta.templateName].mobile.callback
#
#    if 0 < @meta.ieVer <= 9
#      if MMG.Templates[@meta.templateName].ie9
#        if MMG.Templates[@meta.templateName].ie9.template
#          @meta.template = MMG.Templates[@meta.templateName].ie9.template
#        if MMG.Templates[@meta.templateName].ie9.callback
#          @meta.callback = MMG.Templates[@meta.templateName].ie9.callback
#
#    if @meta.ieVer == 8
#      if MMG.Templates[@meta.templateName].ie8
#        if MMG.Templates[@meta.templateName].ie8.template
#          @meta.template = MMG.Templates[@meta.templateName].ie8.template
#        if MMG.Templates[@meta.templateName].ie8.callback
#          @meta.callback = MMG.Templates[@meta.templateName].ie8.callback
          
    return
    
  ###*
  #
  # @method _setLBTemplate
  # @private
  #
  ###
  _setLBTemplate: =>

    MMG.Lightboxes.default = {}  
    MMG.Lightboxes.default.template = 
    """
    <% var title %>
    <% if (data.lb && data.lb.title) { title = data.lb.title %>
    <% } else if (data.face && data.face.title) { title = data.face.title %>
    <% } else { title = data.title } %>
    <div class='<%=meta.NS %>-lb-caption <%=meta.NS %>-lb-default'>
      <div class='<%=meta.NS %>-lb-title'>
      <%= title %>
      </div>
      <div class='<%=meta.NS %>-lb-bg-caption'></div>
    </div>
    """

    MMG.Lightboxes.default.ie9 = {}
    MMG.Lightboxes.default.ie9.callback =->
      self = @
      meta = @model.meta
      meta.root
      .on 'timeForCaption', (event, caption)->

        $(meta.NSclass+'lb-title', caption)
        .stop true
        .delay 200
        .animate opacity: 1

        $(meta.NSclass+'lb-bg-caption', caption)
        .stop true
        .animate
          opacity: 1
          bottom: 0

      meta.root
      .on 'timeForCaptionHide', (event, caption)->
        $(meta.NSclass+'lb-title', caption)
        .stop true
        .animate opacity: 0

        $(meta.NSclass+'lb-bg-caption', caption)
        .stop true
        .delay 200
        .animate
          opacity: 0
          bottom: '-100%'

        return
      return


    
      


    return
  
  
  ###*
  #
  # @method _ieVer
  # @private
  #
  ###
  _ieVer: ->
    ver = 0
    switch
      when document.all && !document.querySelector then ver = 7
      when document.all && !document.addEventListener then ver = 8
      when document.all && !window.atob then ver = 9
      when document.all then ver = 10
    ver



###*
#
# @class MMG.Lightbox.External
#
# Contains 3 static methods which are used by MMG.Grid.Grid class
# for initializing external lightboxes
# 
###


class MMG.Lightbox.External
  
  
  ###*
  #
  # @method colorBox
  # @public
  # @static
  # @param {Object} options - an object of native colorBox options
  # @param {Object} cbs - an object of callbacks: 
  #   getTitle - returns the caption title
  #     default: ''
  #   getHref - returns the src of the image to be shown
  #     default: item.href
  #  @return {colorBox}
  #
  ###
  @colorBox: (options = {},  cbs = {}) ->
    cbs.getTitle ?= (item) -> ''
    cbs.getHref ?= (item) -> item.href
    
    model = @model
    meta = model.meta
    root = meta.root
    rootSelector = meta.grid
    ns = meta.NS
    
    gallery = $()
    
    anchorContainer = $('<div>',
      id: 'anchor-container'
      style: 'display: none').appendTo('body')
      
      
    cb = null
    
    root.on 'dataLoaded', (e, data) ->
    
      if cb
        cb.remove()

      anchorContainer.empty()
      gallery = $()
      
      
      datas = data.all
      datas.forEach (item) ->

        anchor = '<a href="' + cbs.getHref(item) + '" rel="gal" title="' + cbs.getTitle(item) + '"></a>'
        gallery = gallery.add(anchor)
        return
        
      anchorContainer.append gallery
      
      settings = $.extend {}, 
        rel: 'gal'
      , options
      cb = gallery.colorbox settings
      return
      
    $('body').on 'click', ".#{ns}-link", (e) ->
      e.preventDefault()
      id = $(this).parents(".#{ns}-img").attr('data-image-id')
      gallery.eq(id).click()
      return
      
      
  ###*
  #
  # @method prettyPhoto
  # @public
  # @static
  # @param {Object} options - an object of native prettyPhoto options
  # @param {Object} cbs - an object of callbacks: 
  #   getTitle - returns the caption title
  #     default: ''
  #   getDescription - returns the caption description
  #     default: ''
  #   getHref - returns the src of the image to be shown
  #     default: item.href
  #  @return {prettyPhoto}
  #
  ###
  @prettyPhoto: (options = {}, cbs = {}) ->
  
    cbs.getTitle ?= (item) -> ''
    cbs.getDescription ?= (item) -> ''
    cbs.getHref ?= (item) -> item.href
    
    model = @model
    meta = model.meta
    root = meta.root
    rootSelector = meta.grid
    ns = meta.NS
    
    
    ###*
    #
    # sorts the array so that the active element is first one (index = 0)
    # @param {Array} array - an array that to be modified
    # @param {Integer} index - an index of the active element
    # @return {Array}
    #
    ###

    arrayRebuild = (array, index) ->
      part_one = array.slice(0, index)
      part_two = array.slice(index)
      part_two.concat part_one
      
    
    $().prettyPhoto options
    
    images = []
    titles = []
    descriptions = []
    
    root.on 'dataLoaded', (e, data) ->
    
      images = []
      titles = []
      descriptions = []
      
      datas = data.all
      
      datas.forEach (item) ->
        images.push cbs.getHref(item)
        titles.push cbs.getTitle(item)
        descriptions.push cbs.getDescription(item)
        return
      return
      
    $('body').on 'click', ".#{ns}-link", (e) ->
    
      e.preventDefault()
      id = $(this).parents(".#{ns}-img").attr('data-image-id')
      
      images_new = arrayRebuild(images, id)
      titles_new = arrayRebuild(titles, id)
      descriptions_new = arrayRebuild(descriptions, id)
      
      $.prettyPhoto.open images_new, titles_new, descriptions_new
      return
      
    
  ###*
  #
  # @method photoSwipe
  # @public
  # @static
  # @param {Object} options - an object of native photoSwipe options
  # @param {Object} cbs - an object of callbacks: 
  #   getTitle - returns the caption title
  #
  #   getHref - returns the src of the image to be shown
  #     default: item.href
  #   getMsrc - returns the src of the appropriate icon
  #     default: item.src
  #   getWidth: returns the width of the image. Required
  #   getHeight: returns the height of the image. Required
  #
  #   callbacks for reseved params
  #   which anyone can use in his caption templates:
  #   getD1 - returns the value of d1
  #   getD2 - returns the value of d2
  #   getD3 - returns the value of d3
  #   getD4 - returns the value of d4
  #
  #  @return {photoSwipe}
  #
  ###    
  @photoSwipe: (options  ={}, cbs = {}) ->
  
    unless cbs.getHight or cbs.getWidth
      console.error 'getWidth and getHeight must be specified!'
    
    cbs.getMsrc ?= (item) -> item.src
    cbs.getHref ?= (item) -> item.href
    
    model = @model
    meta = model.meta
    root = meta.root
    rootSelector = meta.grid
    ns = meta.NS
    
    #this function returns the items array of objects
    getItems = (data) ->

      result = []
      _.each data, (item) ->
        slide = undefined
        slide = {}
        slide.src = cbs.getHref(item)
        slide.msrc = cbs.getMsrc(item)
        slide.title = cbs.getTitle?(item)
        slide.w = cbs.getWidth(item)
        slide.h = cbs.getHeight(item)
        
        slide.d1 = cbs.getD1?(item)
        slide.d2 = cbs.getD2?(item)
        slide.d3 = cbs.getD3?(item)
        slide.d4 = cbs.getD4?(item)
        
        result.push slide
        return
      result
      
      
    pswpElement = $('.pswp')[0]
    unless pswpElement
      pswpElement = $ "
      <div tabindex='-1' role='dialog' aria-hidden='true' class='pswp'>
        <div class='pswp__bg'></div>
        <div class='pswp__scroll-wrap'>
          <div class='pswp__container'>
            <div class='pswp__item'></div>
            <div class='pswp__item'></div>
            <div class='pswp__item'></div>
          </div>
          <div class='pswp__ui pswp__ui--hidden'>
            <div class='pswp__top-bar'>
              <div class='pswp__counter'></div>
              <button title='Close (Esc)' class='pswp__button pswp__button--close'></button>
              <button title='Share' class='pswp__button pswp__button--share'></button>
              <button title='Toggle fullscreen' class='pswp__button pswp__button--fs'></button>
              <button title='Zoom in/out' class='pswp__button pswp__button--zoom'></button>
              <div class='pswp__preloader'>
                <div class='pswp__preloader__icn'>
                  <div class='pswp__preloader__cut'>
                    <div class='pswp__preloader__donut'></div>
                  </div>
                </div>
              </div>
            </div>
            <div class='pswp__share-modal pswp__share-modal--hidden pswp__single-tap'>
              <div class='pswp__share-tooltip'></div>
            </div>
            <button title='Previous (arrow left)' class='pswp__button pswp__button--arrow--left'></button>
            <button title='Next (arrow right)' class='pswp__button pswp__button--arrow--right'></button>
            <div class='pswp__caption'>
              <div class='pswp__caption__center'></div>
            </div>
          </div>
        </div>
      </div>
      "
      .appendTo 'body'
      .get 0
    
    items = []
    index = 0
    gallery = null
    defaults = index: 0
    $('#container').on 'dataLoaded', (e, data) ->
      length = undefined
      length = data.all.length
      items = getItems(data.all)
      index = length
      return
    $('#container').on 'click', ".#{ns}-link", (e) ->
      e.preventDefault()
      image = $(this).parents(".#{ns}-img")
      index = image.attr('data-image-id') * 1
      defaults =
        index: index
        showAnimationDuration: 500
        hideAnimationDuration: 500
        showHideOpacity: true
        
        getThumbBoundsFn: (index) ->

          thumbnail = image.find(".#{ns}-icon").get(0)
          pageYScroll = window.pageYOffset or document.documentElement.scrollTop
          rect = thumbnail.getBoundingClientRect()
          
          {
            x: rect.left
            y: rect.top + pageYScroll
            w: rect.width
          }
          
      settings = $.extend {}, defaults, options   
      gallery = null
      gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, items, settings)
      gallery.init()
      return




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
  

###*
#
# the factory fanction
#
# @param {String} name - a name of the template
# @param {Object} options
# @param {Boolean} grayscale - if true, the script will create the SVG grayscale
# filter element and append it to the body. Default true.
# @return {MMG.Grid.Grid}
# this factory function is used to create MMG.Grid.Grid class
# it's useful when the template gives us the object of default options
#
# In general it's better to use this function instead of a constructor
#
###


MMG.Gallery  = (name, options, grayscale = true) ->

  defaults = MMG.Templates[name].defaults
  defaults ?= {}
  options ?= {}
  
  settings = $.extend {}, defaults, options
  
  if settings.svgFiltersId == 'grayscale' and grayscale
  
    filterElement = '<svg width="0" height="0"><defs><filter id="grayscale"><fecolormatrix type="saturate" values="0"></fecolormatrix></filter></defs></svg>'
    
    $(filterElement).appendTo 'body'
  
  new MMG.Grid.Grid settings
MMG = window.MMG 

MMG.Templates.Simple = {}

MMG.Templates.Simple.template =

  "
  <div class='<%=meta.NS %>-img <%= data.classList %>'
  data-image-id='<%= imageId %>'>
  <% if(data.href) { %>
    <a href='<%= data.href %>' class='<%=meta.NS %>-link' rel='gal'>
  <% } %>
  <% if(data.face) { %>
    <div class='<%=meta.NS %>-f-caption'>
  <% if(data.face&&data.face.descr) { %>
      <div class='<%=meta.NS %>-descr'>
        <span class='<%=meta.NS %>-caption-bg'>
        <%= data.face.descr %>
        </span>
      </div>
  <% } %>
  <% if(data.face&&data.face.title) { %>
      <h3 class='<%=meta.NS %>-title'>
        <span class='<%=meta.NS %>-title-bg'>
        <%= data.face.title %>
        </span>
      </h3>
  <% } %>
  <% if(data.face&&data.face.secondDescr) { %>
      <div class='<%=meta.NS %>-footer'>
        <span class='<%=meta.NS %>-caption-bg'>
        <%= data.face.secondDescr %>
        </span>
      </div>
  <% } %>
    </div>
  <% } %>
    <img class='<%=meta.NS %>-icon <%=meta.NS %>-fs' src='<%= data.src %>'>
  <% if(data.href) { %>
    </a>
  <% } %>
  </div>
  "
  
MMG.Templates.Simple.defaults =
  templateName: 'Simple'
