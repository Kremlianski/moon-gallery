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



