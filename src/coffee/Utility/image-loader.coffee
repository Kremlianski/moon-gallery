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