###*
#
# @class MMG.View.Image
#
# is used to create a markup for the item
###
class MMG.View.Image

  Models = MMG.Data.Models
  Template = MMG.View.Template
  
  ###*
  #
  # @constructor
  # @param {String} gridId
  # @param {Integer} itemId
  #
  ###

  constructor: (@gridId, @itemId) ->

    @model = Models[@gridId]
    @data = @model.data[@itemId]
    @type = @data.type
    @meta = @model.meta

    @_string = ''
    @image = null

    @_useTemplate()
    @_createImage()
    @_registerImage()
    
  ###*
  #
  # @method _useTemplate
  # @private
  #
  # builds a string from the template
  ###

  _useTemplate: =>
    
    templateName = @meta.templateName
    templateName = @type if @type
    
    compiled = Template.getTemplate(@gridId, templateName).getCompiled()
    @_string = compiled {meta: @meta, data: @data, imageId: @itemId}

    return
    
  ###*
  #
  # @method _createImage
  # @private
  #
  # creates a markup
  ###
  _createImage: =>
    @image = $ @_string
    return

  ###*
  #
  # @method _registerImage
  # @private
  #
  ###
  _registerImage: =>
    @data.image = @image
    return
      
      