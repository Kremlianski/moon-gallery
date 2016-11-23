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

