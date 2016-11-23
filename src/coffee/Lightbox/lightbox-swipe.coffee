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