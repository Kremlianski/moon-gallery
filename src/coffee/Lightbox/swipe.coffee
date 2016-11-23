
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
    