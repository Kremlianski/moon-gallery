
###*

The object with supported canvas filters

###
MMG.Filter.CanvasFilters =

  grayscale: ->
    v = 0.2126 * @rgb.r + 0.7152 * @rgb.g + 0.0722 * @rgb.b
    @rgb.r = @rgb.g = @rgb.b = v
    return

  brightness:(adjust) ->
  
    ###
    Range is -100 to 100
    ###
  
    adjust = Math.floor(adjust * 2.55)
    @rgb.r += adjust
    @rgb.g += adjust
    @rgb.b += adjust
    return

  sepia: ->
    r = @rgb.r * 0.393 + @rgb.g * 0.769 + @rgb.b * 0.189
    g = @rgb.r * 0.349 + @rgb.g * 0.686 + @rgb.b * 0.168
    b = @rgb.r * 0.272 + @rgb.g * 0.534 + @rgb.b * 0.131

    @rgb.r = r
    @rgb.g = g
    @rgb.b = b
    return

  contrast: (adjust) ->
    ###
      Range is -100 to 100
    ###
    adjust = ((adjust + 100) / 100) ** 2
    @rgb.r = ((@rgb.r / 255 - 0.5) * adjust + 0.5) * 255
    @rgb.g = ((@rgb.g / 255 - 0.5) * adjust + 0.5) * 255
    @rgb.b = ((@rgb.b / 255 - 0.5) * adjust + 0.5) * 255
    return

  vibrance: (adjust) ->
    ###
      -100<adjust<100
    ###
    adjust *= -1
    amt = undefined
    avg = undefined
    max = undefined
    max = Math.max(@rgb.r, @rgb.g, @rgb.b)
    avg = (@rgb.r + @rgb.g + @rgb.b) / 3
    amt = Math.abs(max - avg) * 2 / 255 * adjust / 100
    if @rgb.r != max
      @rgb.r += (max - (@rgb.r)) * amt
    if @rgb.g != max
      @rgb.g += (max - (@rgb.g)) * amt
    if @rgb.b != max
      @rgb.b += (max - (@rgb.b)) * amt
    return

  saturate: (adjust) ->
    ###
     Range is -100 to 100
    ###
    adjust *= -0.01
    max = undefined
    max = Math.max(@rgb.r, @rgb.g, @rgb.b)
    if @rgb.r != max
      @rgb.r += (max - (@rgb.r)) * adjust
    if @rgb.g != max
      @rgb.g += (max - (@rgb.g)) * adjust
    if @rgb.b != max
      @rgb.b += (max - (@rgb.b)) * adjust
    return

  colorize: (red, green, blue, adjust) ->
    ###
      0 to 100
    ###
    @rgb.r -= (@rgb.r - red) * adjust / 100
    @rgb.g -= (@rgb.g - green) * adjust / 100
    @rgb.b -= (@rgb.b - blue) * adjust / 100
    return

  noise: (adjust) ->
    ###
      1 - 100
    ###

    randomRange = (min, max, getFloat) ->
      rand = undefined
      if getFloat == null
        getFloat = false
      rand = min + Math.random() * (max - min)
      if getFloat
        rand.toFixed getFloat
      else
        Math.round rand

    adjust = Math.abs(adjust) * 2.55
    rand = randomRange(adjust * -1, adjust)
    @rgb.r += rand
    @rgb.g += rand
    @rgb.b += rand
    return

