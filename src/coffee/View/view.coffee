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
