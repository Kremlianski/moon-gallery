###*
#
# the factory fanction
#
# @param {String} name - a name of the template
# @param {Object} options
# @param {Boolean} grayscale - if true, the script will create the SVG grayscale
# filter element and append it to the body. Default true.
# @return {MMG.Grid.Grid}
# this factory function is used to create MMG.Grid.Grid class
# it's useful when the template gives us the object of default options
#
# In general it's better to use this function instead of a constructor
#
###


MMG.Gallery  = (name, options, grayscale = true) ->

  defaults = MMG.Templates[name].defaults
  defaults ?= {}
  options ?= {}
  
  settings = $.extend {}, defaults, options
  
  if settings.svgFiltersId == 'grayscale' and grayscale
  
    filterElement = '<svg width="0" height="0"><defs><filter id="grayscale"><fecolormatrix type="saturate" values="0"></fecolormatrix></filter></defs></svg>'
    
    $(filterElement).appendTo 'body'
  
  new MMG.Grid.Grid settings