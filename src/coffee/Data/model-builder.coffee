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


