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

