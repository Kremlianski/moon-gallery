###*
#
# @class MMG.Utility.NaturalSize
# for old IE when native naturalWidth/naturalHeight
# are undefined
#
# inspired by Jack Moore
# http://www.jacklmoore.com/notes/naturalwidth-and-naturalheight-in-ie/
#
###

class MMG.Utility.NaturalSize
  ###
  # the Singleton Pattern is used
  #
  ###
  instance = null

  ###*
  #
  # @method set
  # @public
  # @static
  #
  ###
  @set: ->

    instance ?= new PrivatClass()

  ###*
  #
  # @class PrivateClass
  # 
  ###
  class PrivatClass

    ###*
    #
    # @constructor
    #
    ###
    constructor: ->

      @setNaturalSize()
      
      
      
    ###*
    #
    # @method setNaturalSize
    # @public
    #
    ###
    setNaturalSize: ->

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
