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
