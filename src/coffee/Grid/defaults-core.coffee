###*
#
# the set of default options
#
###

MMG.Grid.def =
  onInitCallback: ()->
  afterInitCallback: ()->
  onAjaxCallback: ()->
  afterAjaxCallback: ()->
  insertInImgBeforeCallback: ()->
  insertInImgCallback: ()->
  NS: 'mmg'
  NSclass:'.mmg-'
  NSevent: '.mmg'
  regexMatch: /\.[\w\?=]+$/
  retinaSuffix: '@2x'
  margin: 2
  retina: 0
  maxWait: 5000
  maxSmall: 180
  maxMiddle: 400
  useCanvas: false
  pixelRatio: 1
  filters: null
  SVGFilter: false
  kVisible: 3
  scrollDelta: 1.1
  stop: false
  scrollStop: false
  waitCount: 0
  isMobile: false
  rowWidth: 0
  elementsArray: []
  top: 0
  supportSVGFilters: true
  rowsTop: []
  onViewRowsLength: 0
  lightbox: {}
  oldIEFilter: 'none'