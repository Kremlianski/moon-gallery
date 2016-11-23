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

