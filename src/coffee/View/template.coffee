###*
#
# @class MMG.View.Template
#
#
# When the instance is created the template 
# that has been specified in the options object
# will be compiled by Underscore function 'template'
# 
#
###

class MMG.View.Template

  ###
  the Singleton Pattern is used
  ###

  instance = {}
  models = MMG.Data.Models
  
  ###*
  # @method getTemplate
  # @param {String} gridId
  # @public
  # a static method that is used to call the Template object
  ###

  @getTemplate: (gridId, name, type = 'g')->
    
    adress = '' + gridId + name + type
    instance[adress] ?= new PrivatClass(gridId, name, type)
  
    
    
  ###*
  #
  # @class PrivateClass
  # 
  #
  ###
  class PrivatClass
    ###*
    # @constructor
    # @param {String} adress
    ###
    constructor: (@gridId, @name, @type)->
      @model = models[@gridId]
      @meta = @model.meta
      @compiled = null

      @_setTemplate()

      @_compile()
      
      @_callCallback()
      
    ###*
    # @method getCompiled
    # @public
    #
    # returns the compiled template
    #
    ###

    getCompiled: =>
      @compiled
      
      
    ###*
    # @method _compile
    # @private
    #
    ###

    _compile: =>

      @compiled = _.template @template
      return

    _setTemplate: ->
    
      switch @type
      
        when 'g'
          @_setGTemplate()
        when 'l'
          @_setLTemplate()
          
          
    _setGTemplate: ->
      
      @template = MMG.Templates[@name].template
      @callback = MMG.Templates[@name].callback

      if @meta.isMobile
        if MMG.Templates[@name].mobile
          if MMG.Templates[@name].mobile.template
            @template = MMG.Templates[@name].mobile.template
          if MMG.Templates[@name].mobile.callback
            @callback = MMG.Templates[@name].mobile.callback

      if 0 < @meta.ieVer <= 9
        if MMG.Templates[@name].ie9
          if MMG.Templates[@name].ie9.template
            @template = MMG.Templates[@name].ie9.template
          if MMG.Templates[@name].ie9.callback
            @callback = MMG.Templates[@name].ie9.callback

      if @meta.ieVer == 8
        if MMG.Templates[@name].ie8
          if MMG.Templates[@name].ie8.template
            @template = MMG.Templates[@name].ie8.template
          if MMG.Templates[@name].ie8.callback
            @callback = MMG.Templates[@name].ie8.callback
            
      return
      
      
    _setLTemplate: ->
    
      @template = MMG.Lightboxes[@name].template
      @callback = MMG.Lightboxes[@name].callback
      
      if @meta.isMobile
        if MMG.Lightboxes[@name].mobile
          if MMG.Lightboxes[@name].mobile.template
            @template = MMG.Lightboxes[@name].mobile.template
          if MMG.Lightboxes[@name].mobile.callback
            @callback = MMG.Lightboxes[@name].mobile.callback

      if 0 < @meta.ieVer <= 9
        if MMG.Lightboxes[@name].ie9
          if MMG.Lightboxes[@name].ie9.template
            @template = MMG.Lightboxes[@name].ie9.template
          if MMG.Lightboxes[@name].ie9.callback
            @callback = MMG.Lightboxes[@name].ie9.callback

      if @meta.ieVer == 8
        if MMG.Lightboxes[@name].ie8
          if MMG.Lightboxes[@name].ie8.template
            @template = MMG.Lightboxes[@name].ie8.template
          if MMG.Lightboxes[@name].ie8.callback
            @callback = MMG.Lightboxes[@name].ie8.callback
    
    _callCallback: ->
      if @callback and _.isFunction @callback
        @callback.call @