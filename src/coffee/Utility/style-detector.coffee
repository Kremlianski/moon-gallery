###*
#
# @class MMG.Utility.StyleDetector
#
# Detects CSS Style Support
#
# inspired by Ryan Morr
# http://ryanmorr.com/detecting-css-style-support/
#
#
# You can use this class in your templates
###


class MMG.Utility.StyleDetector

  ###*
  #
  # @method isStyleSupported
  # @public
  # @static
  # @param {String} prop - tested property
  # @param {String} value - "inherit", if no value is supplied
  #
  ###
  
  @isStyleSupported: (prop, value) ->
    el = window.document.createElement('div')
    camelRe = /-([a-z]|[0-9])/ig
    ###
    # If no value is supplied, use "inherit"
    ###
    value = if arguments.length == 2 then value else 'inherit'
    ###
    # Try the native standard method first
    ###
    if 'CSS' of window and 'supports' of window.CSS
      return window.CSS.supports(prop, value)
    ###
    # Check Opera's native method
    ###
    if 'supportsCSS' of window
      return window.supportsCSS(prop, value)
    ###
    # Convert to camel-case for DOM interactions
    ###
    camel = prop.replace(camelRe, (all, letter) ->
      (letter + '').toUpperCase()
    )
    ###
    # Check if the property is supported
    ###
    support = camel of el.style
    ###
    # Assign the property and value to invoke
    # the CSS interpreter
    ###
    el.style.cssText = prop + ':' + value
    ###
    # Ensure both the property and value are
    # supported and return
    ###
    support and el.style[camel] != ''

