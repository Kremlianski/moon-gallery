
/**

Moon Mega Grid

@author Alexandre Kremlianski (kremlianski@gmail.com)
 
@version 2.9

@requires jQuery
@requires Underscore.js
@requires jquery-scrollstop
 */

(function() {
  var MMG,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.MMG = {
    Grid: {},
    Data: {},
    Utility: {},
    View: {},
    AJAX: {},
    Drawing: {},
    Filter: {},
    Templates: {},
    Lightbox: {},
    Lightboxes: {}
  };


  /*
    Namespace for all classes of this project
   */

  MMG = window.MMG;


  /**
   *
   * @class MMG.Utility.StyleDetector
   *
   * Detects CSS Style Support
   *
   * inspired by Ryan Morr
   * http://ryanmorr.com/detecting-css-style-support/
   *
   *
   * You can use this class in your templates
   */

  MMG.Utility.StyleDetector = (function() {
    function StyleDetector() {}


    /**
     *
     * @method isStyleSupported
     * @public
     * @static
     * @param {String} prop - tested property
     * @param {String} value - "inherit", if no value is supplied
     *
     */

    StyleDetector.isStyleSupported = function(prop, value) {
      var camel, camelRe, el, support;
      el = window.document.createElement('div');
      camelRe = /-([a-z]|[0-9])/ig;

      /*
       * If no value is supplied, use "inherit"
       */
      value = arguments.length === 2 ? value : 'inherit';

      /*
       * Try the native standard method first
       */
      if ('CSS' in window && 'supports' in window.CSS) {
        return window.CSS.supports(prop, value);
      }

      /*
       * Check Opera's native method
       */
      if ('supportsCSS' in window) {
        return window.supportsCSS(prop, value);
      }

      /*
       * Convert to camel-case for DOM interactions
       */
      camel = prop.replace(camelRe, function(all, letter) {
        return (letter + '').toUpperCase();
      });

      /*
       * Check if the property is supported
       */
      support = camel in el.style;

      /*
       * Assign the property and value to invoke
       * the CSS interpreter
       */
      el.style.cssText = prop + ':' + value;

      /*
       * Ensure both the property and value are
       * supported and return
       */
      return support && el.style[camel] !== '';
    };

    return StyleDetector;

  })();


  /*
  the Object that will store all data
   */

  MMG.Data.Models = {};


  /**
  
  The object with supported canvas filters
   */

  MMG.Filter.CanvasFilters = {
    grayscale: function() {
      var v;
      v = 0.2126 * this.rgb.r + 0.7152 * this.rgb.g + 0.0722 * this.rgb.b;
      this.rgb.r = this.rgb.g = this.rgb.b = v;
    },
    brightness: function(adjust) {

      /*
      Range is -100 to 100
       */
      adjust = Math.floor(adjust * 2.55);
      this.rgb.r += adjust;
      this.rgb.g += adjust;
      this.rgb.b += adjust;
    },
    sepia: function() {
      var b, g, r;
      r = this.rgb.r * 0.393 + this.rgb.g * 0.769 + this.rgb.b * 0.189;
      g = this.rgb.r * 0.349 + this.rgb.g * 0.686 + this.rgb.b * 0.168;
      b = this.rgb.r * 0.272 + this.rgb.g * 0.534 + this.rgb.b * 0.131;
      this.rgb.r = r;
      this.rgb.g = g;
      this.rgb.b = b;
    },
    contrast: function(adjust) {

      /*
        Range is -100 to 100
       */
      adjust = Math.pow((adjust + 100) / 100, 2);
      this.rgb.r = ((this.rgb.r / 255 - 0.5) * adjust + 0.5) * 255;
      this.rgb.g = ((this.rgb.g / 255 - 0.5) * adjust + 0.5) * 255;
      this.rgb.b = ((this.rgb.b / 255 - 0.5) * adjust + 0.5) * 255;
    },
    vibrance: function(adjust) {

      /*
        -100<adjust<100
       */
      var amt, avg, max;
      adjust *= -1;
      amt = void 0;
      avg = void 0;
      max = void 0;
      max = Math.max(this.rgb.r, this.rgb.g, this.rgb.b);
      avg = (this.rgb.r + this.rgb.g + this.rgb.b) / 3;
      amt = Math.abs(max - avg) * 2 / 255 * adjust / 100;
      if (this.rgb.r !== max) {
        this.rgb.r += (max - this.rgb.r) * amt;
      }
      if (this.rgb.g !== max) {
        this.rgb.g += (max - this.rgb.g) * amt;
      }
      if (this.rgb.b !== max) {
        this.rgb.b += (max - this.rgb.b) * amt;
      }
    },
    saturate: function(adjust) {

      /*
       Range is -100 to 100
       */
      var max;
      adjust *= -0.01;
      max = void 0;
      max = Math.max(this.rgb.r, this.rgb.g, this.rgb.b);
      if (this.rgb.r !== max) {
        this.rgb.r += (max - this.rgb.r) * adjust;
      }
      if (this.rgb.g !== max) {
        this.rgb.g += (max - this.rgb.g) * adjust;
      }
      if (this.rgb.b !== max) {
        this.rgb.b += (max - this.rgb.b) * adjust;
      }
    },
    colorize: function(red, green, blue, adjust) {

      /*
        0 to 100
       */
      this.rgb.r -= (this.rgb.r - red) * adjust / 100;
      this.rgb.g -= (this.rgb.g - green) * adjust / 100;
      this.rgb.b -= (this.rgb.b - blue) * adjust / 100;
    },
    noise: function(adjust) {

      /*
        1 - 100
       */
      var rand, randomRange;
      randomRange = function(min, max, getFloat) {
        var rand;
        rand = void 0;
        if (getFloat === null) {
          getFloat = false;
        }
        rand = min + Math.random() * (max - min);
        if (getFloat) {
          return rand.toFixed(getFloat);
        } else {
          return Math.round(rand);
        }
      };
      adjust = Math.abs(adjust) * 2.55;
      rand = randomRange(adjust * -1, adjust);
      this.rgb.r += rand;
      this.rgb.g += rand;
      this.rgb.b += rand;
    }
  };


  /**
   *
   * @class MMG.Utility.Queue
   * the general class for creating Queue objects
   *
   */

  MMG.Utility.Queue = (function() {

    /**
     * @constructor
     */
    function Queue() {
      this.size = bind(this.size, this);
      this.put = bind(this.put, this);
      this.take = bind(this.take, this);
      this.stac = new Array;
    }


    /**
     *
     * @method take
     * @public
     * @return {Object}
     *
     */

    Queue.prototype.take = function() {
      return this.stac.shift();
    };


    /**
     *
     * @method put
     * @public
     * @param {Object} item the Object to be stored in the Queue
     *
     */

    Queue.prototype.put = function(item) {
      this.stac.push(item);
      return this.stac.length;
    };


    /**
     * @method size
     * @public
     * @return {Integer}
     */

    Queue.prototype.size = function() {
      return this.stac.length;
    };

    return Queue;

  })();


  /**
   *
   * @class MMG.Filter.CanvasFilter
   * 
   *
   */

  MMG.Filter.CanvasFilter = (function() {

    /*
    the Singleton Pattern is used
     */
    var PrivatClass, filters, instance, models;

    function CanvasFilter() {}

    instance = {};

    models = MMG.Data.Models;

    filters = MMG.Filter.CanvasFilters;


    /**
     * @method getFilter
     * @param {String} gridId
     * @public
     * a static method that is used to call the CanvasFilter object
     */

    CanvasFilter.getFilter = function(gridId) {
      return instance[gridId] != null ? instance[gridId] : instance[gridId] = new PrivatClass(gridId);
    };


    /**
     *
     * @class PrivateClass
     * 
     *
     */

    PrivatClass = (function() {

      /**
       * @constructor
       * @param {String} gridId
       */
      function PrivatClass(gridId1) {
        this.gridId = gridId1;
        this.applyFilter = bind(this.applyFilter, this);
        this._loadFilters = bind(this._loadFilters, this);
        this.model = models[this.gridId];
        this.meta = this.model.meta;
        this.rgb = {};
        this.filtersList = this._loadFilters();
      }


      /**
       *
       * @method _loadFilters
       * @private
       * @return {Function}
       *
       */

      PrivatClass.prototype._loadFilters = function() {
        var func, i;
        func = '';
        i = 0;
        while (i < this.meta.filters.length) {
          func += 'filters[this.meta.filters[' + i + '][0]].apply(this, this.meta.filters[' + i + '][1]);';
          i++;
        }
        return new Function('filters', func);
      };


      /**
       *
       * @method applyFilter
       * @public
       * @param {RenderingContext} context
       * @param {HTMLCanvasElement} canvas
       *
       */

      PrivatClass.prototype.applyFilter = function(context, canvas) {
        var d, i, imageData;
        imageData = context.getImageData(0, 0, canvas.width, canvas.height);
        d = imageData.data;
        i = 0;
        while (i < d.length) {
          this.rgb.r = d[i];
          this.rgb.g = d[i + 1];
          this.rgb.b = d[i + 2];
          this.filtersList.call(this, filters);
          d[i] = this.rgb.r;
          d[i + 1] = this.rgb.g;
          d[i + 2] = this.rgb.b;
          this.rgb = {};
          i += 4;
        }
        context.putImageData(imageData, 0, 0);
      };

      return PrivatClass;

    })();

    return CanvasFilter;

  })();


  /**
   *
   * @class MMG.View.Template
   *
   *
   * When the instance is created the template 
   * that has been specified in the options object
   * will be compiled by Underscore function 'template'
   * 
   *
   */

  MMG.View.Template = (function() {

    /*
    the Singleton Pattern is used
     */
    var PrivatClass, instance, models;

    function Template() {}

    instance = {};

    models = MMG.Data.Models;


    /**
     * @method getTemplate
     * @param {String} gridId
     * @public
     * a static method that is used to call the Template object
     */

    Template.getTemplate = function(gridId, name, type) {
      var adress;
      if (type == null) {
        type = 'g';
      }
      adress = '' + gridId + name + type;
      return instance[adress] != null ? instance[adress] : instance[adress] = new PrivatClass(gridId, name, type);
    };


    /**
     *
     * @class PrivateClass
     * 
     *
     */

    PrivatClass = (function() {

      /**
       * @constructor
       * @param {String} adress
       */
      function PrivatClass(gridId1, name1, type1) {
        this.gridId = gridId1;
        this.name = name1;
        this.type = type1;
        this._compile = bind(this._compile, this);
        this.getCompiled = bind(this.getCompiled, this);
        this.model = models[this.gridId];
        this.meta = this.model.meta;
        this.compiled = null;
        this._setTemplate();
        this._compile();
        this._callCallback();
      }


      /**
       * @method getCompiled
       * @public
       *
       * returns the compiled template
       *
       */

      PrivatClass.prototype.getCompiled = function() {
        return this.compiled;
      };


      /**
       * @method _compile
       * @private
       *
       */

      PrivatClass.prototype._compile = function() {
        this.compiled = _.template(this.template);
      };

      PrivatClass.prototype._setTemplate = function() {
        switch (this.type) {
          case 'g':
            return this._setGTemplate();
          case 'l':
            return this._setLTemplate();
        }
      };

      PrivatClass.prototype._setGTemplate = function() {
        var ref;
        this.template = MMG.Templates[this.name].template;
        this.callback = MMG.Templates[this.name].callback;
        if (this.meta.isMobile) {
          if (MMG.Templates[this.name].mobile) {
            if (MMG.Templates[this.name].mobile.template) {
              this.template = MMG.Templates[this.name].mobile.template;
            }
            if (MMG.Templates[this.name].mobile.callback) {
              this.callback = MMG.Templates[this.name].mobile.callback;
            }
          }
        }
        if ((0 < (ref = this.meta.ieVer) && ref <= 9)) {
          if (MMG.Templates[this.name].ie9) {
            if (MMG.Templates[this.name].ie9.template) {
              this.template = MMG.Templates[this.name].ie9.template;
            }
            if (MMG.Templates[this.name].ie9.callback) {
              this.callback = MMG.Templates[this.name].ie9.callback;
            }
          }
        }
        if (this.meta.ieVer === 8) {
          if (MMG.Templates[this.name].ie8) {
            if (MMG.Templates[this.name].ie8.template) {
              this.template = MMG.Templates[this.name].ie8.template;
            }
            if (MMG.Templates[this.name].ie8.callback) {
              this.callback = MMG.Templates[this.name].ie8.callback;
            }
          }
        }
      };

      PrivatClass.prototype._setLTemplate = function() {
        var ref;
        this.template = MMG.Lightboxes[this.name].template;
        this.callback = MMG.Lightboxes[this.name].callback;
        if (this.meta.isMobile) {
          if (MMG.Lightboxes[this.name].mobile) {
            if (MMG.Lightboxes[this.name].mobile.template) {
              this.template = MMG.Lightboxes[this.name].mobile.template;
            }
            if (MMG.Lightboxes[this.name].mobile.callback) {
              this.callback = MMG.Lightboxes[this.name].mobile.callback;
            }
          }
        }
        if ((0 < (ref = this.meta.ieVer) && ref <= 9)) {
          if (MMG.Lightboxes[this.name].ie9) {
            if (MMG.Lightboxes[this.name].ie9.template) {
              this.template = MMG.Lightboxes[this.name].ie9.template;
            }
            if (MMG.Lightboxes[this.name].ie9.callback) {
              this.callback = MMG.Lightboxes[this.name].ie9.callback;
            }
          }
        }
        if (this.meta.ieVer === 8) {
          if (MMG.Lightboxes[this.name].ie8) {
            if (MMG.Lightboxes[this.name].ie8.template) {
              this.template = MMG.Lightboxes[this.name].ie8.template;
            }
            if (MMG.Lightboxes[this.name].ie8.callback) {
              return this.callback = MMG.Lightboxes[this.name].ie8.callback;
            }
          }
        }
      };

      PrivatClass.prototype._callCallback = function() {
        if (this.callback && _.isFunction(this.callback)) {
          return this.callback.call(this);
        }
      };

      return PrivatClass;

    })();

    return Template;

  })();


  /**
   *
   * @class MMG.Utility.QueueSingleton
   */

  MMG.Utility.QueueSingleton = (function() {

    /*
    the Singleton Pattern is used
     */
    var PrivateClass, Queue, instance;

    function QueueSingleton() {}

    instance = {};

    Queue = MMG.Utility.Queue;


    /**
     * @method getQueue
     * @param {String} gridId
     * @public
     * a static method that is used to call the QueueSingleton instance
     */

    QueueSingleton.getQueue = function(gridId) {
      return instance[gridId] != null ? instance[gridId] : instance[gridId] = new PrivateClass();
    };


    /**
     *
     * @class PrivateClass
     * 
     *
     */

    PrivateClass = (function(superClass) {
      extend(PrivateClass, superClass);


      /**
       * @constructor
       * @param {String} gridId
       */

      function PrivateClass() {
        this._slow = bind(this._slow, this);
        this._check = bind(this._check, this);
        this.execute = bind(this.execute, this);
        PrivateClass.__super__.constructor.call(this);
      }


      /**
       *
       * @method execute
       * @param {Array} func  First element is a function,
       *  second - a Row object
       * @public
       *
       * puts the function into the Queue
       */

      PrivateClass.prototype.execute = function(func) {
        if (this.size() === 0) {
          this.put(func);
          return this._slow();
        } else {
          return this.put(func);
        }
      };


      /**
       * @method _check
       * @private
       *
       */

      PrivateClass.prototype._check = function() {
        var take;
        take = this.take();
        if (!take) {
          return false;
        }
        if (!take[1].inView) {
          return take = this._check();
        } else {
          return take[0];
        }
      };


      /**
       * @method _slow
       * @private
       * executes func[0] if func[1] is in view
       */

      PrivateClass.prototype._slow = function() {
        return setTimeout((function(_this) {
          return function() {
            var func;
            func = _this._check();
            if (!func) {
              return;
            }
            func();
            return _this._slow();
          };
        })(this), 50);
      };

      return PrivateClass;

    })(Queue);

    return QueueSingleton;

  })();


  /**
   *
   * @class MMG.Utility.QueueSimple
   */

  MMG.Utility.QueueSimple = (function() {

    /*
    the Singleton Pattern is used
     */
    var PrivateClass, Queue, instance;

    function QueueSimple() {}

    instance = {};

    Queue = MMG.Utility.Queue;


    /**
     * @method getQueue
     * @param {String} gridId
     * @public
     * a static method that is used to call the QueueSimple instance
     */

    QueueSimple.getQueue = function(gridId) {
      return instance[gridId] != null ? instance[gridId] : instance[gridId] = new PrivateClass();
    };


    /**
     *
     * @class PrivateClass
     * 
     *
     */

    PrivateClass = (function(superClass) {
      extend(PrivateClass, superClass);


      /**
       * @constructor
       * @param {String} gridId
       */

      function PrivateClass() {
        this._slow = bind(this._slow, this);
        this.execute = bind(this.execute, this);
        PrivateClass.__super__.constructor.call(this);
      }


      /**
       *
       * @method execute
       * @param {Function} func  
       * @public
       *
       * puts the function into the Queue
       */

      PrivateClass.prototype.execute = function(func) {
        if (this.size() === 0) {
          this.put(func);
          return this._slow();
        } else {
          return this.put(func);
        }
      };


      /**
       * @method _slow
       * @private
       * executes func
       */

      PrivateClass.prototype._slow = function() {
        return setTimeout((function(_this) {
          return function() {
            var func;
            func = _this.take();
            if (!func) {
              return;
            }
            func();
            return _this._slow();
          };
        })(this), 50);
      };

      return PrivateClass;

    })(Queue);

    return QueueSimple;

  })();


  /**
   *
   * @class MMG.Drawing.DrawingSVG
   * 
   * creates a SVG element
   */

  MMG.Drawing.DrawingSVG = (function() {
    var models;

    models = MMG.Data.Models;


    /**
     * @constructor
     * @param {String} gridId
     * @param {Object} item - the object with data for this item
     * @param {HTMLElement} parent - the image parent element
     */

    function DrawingSVG(gridId1, item, parent) {
      this.gridId = gridId1;
      this._cleanMemory = bind(this._cleanMemory, this);
      this._drawImage = bind(this._drawImage, this);
      this._initializeSVG = bind(this._initializeSVG, this);
      this.model = models[this.gridId];
      this.meta = this.model.meta;
      this.retina = this.meta.retina;
      this.filters = this.meta.svgFiltersId;
      this.image = item;
      this.url = this.image.src;
      this.width = this.image.newWidth;
      this.height = this.image.newHeight;
      this.containerParent = parent;
      this._initializeSVG();
    }


    /**
     * @method _initializeSVG
     * @private
     */

    DrawingSVG.prototype._initializeSVG = function() {
      var svgHeight, svgWidth;
      this.svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      this.containerWidth = Math.round(this.width);
      this.containerHeight = Math.round(this.height);
      this.svg.setAttribute('width', this.containerWidth);
      this.svg.setAttribute('height', this.containerHeight);
      this.svg.setAttribute('viewBox', '0 0 ' + this.containerWidth + ' ' + this.containerHeight);
      this.containerParent.appendChild(this.svg);
      this.svg.width = this.containerWidth;
      this.svg.style.width = this.containerWidth;
      this.svg.height = this.containerHeight;
      this.svg.style.height = this.containerHeight;
      this.svg.viewBox = '0 0 ' + this.svg.width + ' ' + this.svg.height;
      if (window.devicePixelRatio > 1 && this.retina > 0) {
        svgWidth = this.svg.width;
        svgHeight = this.svg.height;
        this.svg.width = svgWidth * window.devicePixelRatio;
        this.svg.height = svgHeight * window.devicePixelRatio;
        this.svg.style.width = svgWidth;
        this.svg.style.height = svgHeight;
      }
      this._drawImage();
    };


    /**
     * @method _drawImage
     * @private
     */

    DrawingSVG.prototype._drawImage = function() {
      var image;
      image = document.createElementNS('http://www.w3.org/2000/svg', 'image');
      $(image).attr({
        width: this.containerWidth,
        height: this.containerHeight,
        filter: "url(#" + this.filters + ")"
      });
      image.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', this.url);
      this.svg.appendChild(image);
      this._cleanMemory();
    };


    /**
     * @method _cleanMemory
     * @private
     */

    DrawingSVG.prototype._cleanMemory = function() {
      this.retina = null;
      this.svg = null;
      this.filters = null;
      this.image = null;
      this.url = null;
      this.width = null;
      this.height = null;
      this.containerParent = null;
    };

    return DrawingSVG;

  })();


  /**
   *
   * @class MMG.Drawing.Drawing
   * 
   * creates a canvas element and applies filters
   */

  MMG.Drawing.Drawing = (function() {
    var CanvasFilter, models;

    models = MMG.Data.Models;

    CanvasFilter = MMG.Filter.CanvasFilter;


    /**
     * @constructor
     * @param {String} gridId
     * @param {HTMLImageElement} item
     */

    function Drawing(gridId1, item) {
      this.gridId = gridId1;
      this._cleanMemory = bind(this._cleanMemory, this);
      this._getAffectedRectangle = bind(this._getAffectedRectangle, this);
      this._drawImage = bind(this._drawImage, this);
      this._initializeCanvas = bind(this._initializeCanvas, this);
      this._loadImage = bind(this._loadImage, this);
      this.model = models[this.gridId];
      this.meta = this.model.meta;
      this.data = this.model.data;
      this.retina = this.meta.retina;
      this.filters = this.meta.filters;
      this.twin = this.meta.twin;
      this.container = item;
      this.sourceURL = this.container.getAttribute('src');
      this._loadImage(this.sourceURL, this._initializeCanvas);
    }


    /**
     *
     * @method _loadImage
     * @private
     * @param {String} URL
     * @param {Function} callback - the function to be executed when 
     * the image is loaded
     *
     * loads the image
     */

    Drawing.prototype._loadImage = function(URL, callback) {
      this.imageObject = this.container;
      if (this.container.tagName.toLowerCase() !== 'img') {
        this.imageObject = document.createElement('img');
      }
      this.imageObject.onload = callback.bind(this);
      if (this.container.tagName.toLowerCase() !== 'img') {
        this.imageObject.src = URL;
      }
      if (this.imageObject.complete) {
        callback();
      }
    };


    /**
     *
     * @method _initializeCanvas
     * @private
     */

    Drawing.prototype._initializeCanvas = function() {
      var canvasHeight, canvasWidth;
      this.imageObject.onload = null;
      this.rgb = {};
      this.canvas = document.createElement('canvas');
      this.containerParent = this.container.parentNode;
      this.containerWidth = this.container.offsetWidth;
      this.containerHeight = this.container.offsetHeight;
      this._insertAfter(this.container, this.canvas);
      this.context = this.canvas.getContext('2d');
      this.canvas.width = this.containerWidth;
      this.canvas.style.width = this.container.style.width;
      this.canvas.height = this.containerHeight;
      this.canvas.style.height = this.container.style.height;
      this.canvas.style.top = this.container.style.top;
      this.canvas.style.left = this.container.style.left;
      this.canvas.style.maxWidth = this.container.style.maxWidth;
      this.canvas.style.maxHeight = this.container.style.maxHeight;
      if (window.devicePixelRatio > 1 && this.retina > 0) {
        canvasWidth = this.canvas.width;
        canvasHeight = this.canvas.height;
        this.canvas.width = canvasWidth * window.devicePixelRatio;
        this.canvas.height = canvasHeight * window.devicePixelRatio;
        this.canvas.style.width = canvasWidth;
        this.canvas.style.height = canvasHeight;
        this.context.scale(window.devicePixelRatio, window.devicePixelRatio);
      }
      this._drawImage();
    };


    /**
     *
     * @method _drawImage
     * @private
     */

    Drawing.prototype._drawImage = function() {
      var affectedRectangle, filter;
      affectedRectangle = this._getAffectedRectangle(this.imageObject);
      this.context.drawImage(this.imageObject, 0, 0, affectedRectangle.width, affectedRectangle.height);
      if (this.meta.filters) {
        filter = CanvasFilter.getFilter(this.gridId);
        filter.applyFilter(this.context, this.canvas);
      }
      this._cleanMemory();
    };


    /**
     *
     * @method _getAffectedRectangle
     * @private
     * @return {Object}
     *
     * returns an object with width and height of the image
     */

    Drawing.prototype._getAffectedRectangle = function() {
      var rectangle;
      rectangle = {};
      rectangle.width = this.containerWidth;
      rectangle.height = this.containerHeight;
      return rectangle;
    };


    /**
     *
     * @method _cleanMemory
     * @private
     */

    Drawing.prototype._cleanMemory = function() {
      if (!this.twin) {
        this.imageObject.src = '';
        this.containerParent.removeChild(this.container);
        delete this.container;
        if (this.container !== this.imageObject) {
          delete this.imageObject;
        }
        this.container = null;
        this.imageObject = null;
      }
      delete this.context;
      this.canvas = null;
      this.context = null;
      this.containerParent = null;
      this.containerWidth = null;
      this.containerHeight = null;
      this.sourceURL = null;
      this.rgb = null;
      this.filters = null;
    };


    /**
     *
     * @method _insertAfter
     * @private
     * @param {HTMLElement} referenceNode
     * @param {HTMLElement} newNode
     */

    Drawing.prototype._insertAfter = function(referenceNode, newNode) {
      referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
    };

    return Drawing;

  })();


  /**
   *
   * the object that stores data about rows
   */

  MMG.Data.Rows = {};


  /**
   *
   * @class MMG.View.Row
   *
   */

  MMG.View.Row = (function() {
    var Drawing, DrawingSVG, Img, Queue, models, rows;

    models = MMG.Data.Models;

    rows = MMG.Data.Rows;

    Img = MMG.View.Image;

    Drawing = MMG.Drawing.Drawing;

    DrawingSVG = MMG.Drawing.DrawingSVG;

    Queue = MMG.Utility.QueueSingleton;


    /**
     *
     * @constructor
     * @param {String} gridId
     *
     */

    function Row(gridId1) {
      this.gridId = gridId1;
      this._showImages = bind(this._showImages, this);
      this._showImage = bind(this._showImage, this);
      this._hideImages = bind(this._hideImages, this);
      this._scroll = bind(this._scroll, this);
      this._onScroll = bind(this._onScroll, this);
      this._isInView = bind(this._isInView, this);
      this._getClass = bind(this._getClass, this);
      this.resize = bind(this.resize, this);
      this.needNew = bind(this.needNew, this);
      this.registerImage = bind(this.registerImage, this);
      this._register = bind(this._register, this);
      this.calculate = bind(this.calculate, this);
      this._makeRow = bind(this._makeRow, this);
      this.model = models[this.gridId];
      this.meta = this.model.meta;
      this.data = this.model.data;
      this.rowData = {
        images: [],
        finished: true,
        row: null
      };
      this.row = null;
      this.rows = rows[this.gridId].data;
      this.rowMeta = rows[this.gridId].meta;
      this.rowId = this.rows.length;
      this.images = [];
      this.width = 0;
      this.height = this.meta.minHeight;
      this.queue = Queue.getQueue(this.gridId);
      this._makeRow();
      this._register();
    }


    /**
     *
     * @method _makeRow
     * @private
     *
     * creates html-element
     *
     */

    Row.prototype._makeRow = function() {
      var rowString;
      rowString = "<div class='" + this.meta.NS + "-row'></div>";
      this.row = $(rowString);
      this.rowData.row = this.row;
    };


    /**
     *
     * @method calculate
     * @public
     * @param {Object} item
     *
     *
     */

    Row.prototype.calculate = function(item) {
      var minWidth;
      minWidth = this.meta.minHeight * item.ratio;
      this.rowData.width = this.width += minWidth + this.meta.margin;
      item.newWidth = minWidth;
      item.newHeight = this.meta.minHeight;
      return true;
    };


    /**
     *
     * @method _register
     * @private
     *
     */

    Row.prototype._register = function() {
      this.rows[this.rowId] = this.rowData;
    };


    /**
     *
     * @method registerImage
     * @public
     * @param {Integer} i
     *
     */

    Row.prototype.registerImage = function(i) {
      this.rowData.images.push(i);
    };


    /**
     *
     * @method needNew
     * @public
     * @return {Boolean}
     *
     * returns 'true' if the row needs more items
     *
     */

    Row.prototype.needNew = function() {
      var width;
      width = this.width - this.meta.margin;
      if (this.meta.root.width() - width > 0) {
        return false;
      }
      return true;
    };


    /**
     *
     * @method resize
     * @public
     *
     * When the row width is bigger then expected
     * this method specifies a new width and a new height
     * for every item in the row
     *
     */

    Row.prototype.resize = function() {
      var length, margin, minHeight, newHeight, realWidth, root, rowElements, self;
      self = this;
      margin = this.meta.margin;
      realWidth = this.width - margin;
      minHeight = newHeight = this.meta.minHeight;
      root = this.meta.root;
      length = this.rowData.images.length;
      if (realWidth > root.width()) {
        newHeight = (root.width() - margin * (length - 1)) / (realWidth - margin * (length - 1)) * minHeight;
        rowElements = _.map(this.rowData.images, function(item) {
          var image, newWidth, ratio, sizeClass;
          image = self.data[item];
          ratio = image.ratio;
          newWidth = newHeight * ratio;
          image.newWidth = newWidth;
          image.newHeight = newHeight;
          sizeClass = self._getClass(newWidth);
          image.image.css({
            width: newWidth,
            height: newHeight
          });
          if (sizeClass != null) {
            image.image.addClass(sizeClass);
          }
          $(self.meta.NSclass + "fs", image.image.get(0)).css({
            width: newWidth,
            height: newHeight
          });
          return image;
        });
        this.row.css({
          height: newHeight + 'px',
          width: root.width() + 100 + 'px',
          display: 'block',
          'margin-bottom': margin + 'px'
        });
        this.rowData.finished = true;
      } else {
        _.each(this.rowData.images, function(item) {
          var image;
          image = self.data[item];
          image.image.css({
            width: image.newWidth,
            height: newHeight
          });
          $(self.meta.NSclass + "fs", image.image.get(0)).css({
            width: image.newWidth,
            height: newHeight
          });
        });
        this.row.css({
          height: newHeight + 'px',
          width: root.width() + 100 + 'px',
          display: 'block',
          'margin-bottom': margin + 'px'
        });
      }
      this.rowData.height = newHeight;
      if (this.rowId === 0) {
        this.rowData.top = 0;
      } else {
        this.rowData.top = this.meta.margin + this.rows[this.rowId - 1].top + newHeight;
      }
      this.rowMeta.scrollTop = $(document).scrollTop();
      this.rowMeta.scrollLeft = $(document).scrollLeft();
      this.rowData.inView = this._isInView();
      if (!this.rowData.inView) {
        this._hideImages();
      }
    };


    /**
     *
     * @method _getClass
     * @private
     * @param {Integer} width
     *
     * specifies a 'size class': 
     * 'mmg-small' or 'mmg-middle' or undefined
     */

    Row.prototype._getClass = function(width) {
      var res;
      res = null;
      switch (false) {
        case !(width <= this.meta.maxSmall):
          res = this.meta.NS + '-small';
          break;
        case !(width <= this.meta.maxMiddle):
          res = this.meta.NS + '-middle';
      }
      return res;
    };


    /**
     *
     * @method _isInView
     * @private
     * @return {Boolean}
     *
     * culcilates if the row is in view
     */

    Row.prototype._isInView = function() {
      return Row.isRowInView(this.rowData, this.meta, this.rowMeta);
    };

    Row.isRowInView = function(rowData, meta, rowMeta) {
      var elemBottom, elemTop, k;
      if (meta.ieVer === 8) {
        return true;
      }
      k = meta.kVisible;
      elemTop = rowData.top - rowMeta.scrollTop + meta.root.offset().top;
      elemBottom = elemTop + rowData.height;
      k = k || 1;
      return elemTop <= meta.winHeight * (k + 1) && elemBottom + meta.winHeight * k >= 0;
    };


    /**
     *
     * @method _onScroll
     * @private
     *
     * is not used
     *
     */

    Row.prototype._onScroll = function() {
      var throttled;
      throttled = _.throttle(this._scroll, 100);
      $(document).on('scroll', throttled);
    };


    /**
     *
     * @method _scroll
     * @private
     *
     * is not used
     *
     */

    Row.prototype._scroll = function() {
      this.rowMeta.scrollTop = $(document).scrollTop();
      this.rowMeta.scrollLeft = $(document).scrollLeft();
      if (this._isInView()) {
        this.queue.execute(_.bind(this._showImages, this));
      } else {
        this._hideImages();
      }
    };


    /**
     *
     * @method _hideImages
     * @private
     *
     * 'hides' items witch are not in view
     *
     */

    Row.prototype._hideImages = function() {
      if (!this.data[this.rowData.images[0]].image) {
        return;
      }
      _.each(this.rowData.images, (function(_this) {
        return function(item) {
          var image;
          image = models[_this.gridId].data[item].image;
          image.remove();
          image = null;
          delete models[_this.gridId].data[item].image;
          return false;
        };
      })(this));
      this.rowData.inView = false;
    };


    /**
     *
     * @method _showImage
     * @private
     *
     * 'shows' item that is not in view
     * 
     * is not used
     */

    Row.prototype._showImage = function(item) {
      var $image, drawing, image, parent, sizeClass, tmp, tmpImg;
      image = new Img(this.gridId, item);
      $image = image.image.appendTo(this.row).css({
        'margin-right': this.meta.margin + 'px',
        height: this.data[item].newHeight + 'px',
        width: this.data[item].newWidth + 'px'
      });
      sizeClass = this._getClass(this.data[item].newWidth);
      if (sizeClass != null) {
        $image.addClass(sizeClass);
      }
      $(this.meta.NSclass + 'fs', $image.get(0)).css({
        height: this.data[item].newHeight + 'px',
        width: this.data[item].newWidth + 'px'
      });
      switch (false) {
        case !this.meta.useCanvas:
          drawing = Drawing.getDrawing(this.gridId);
          tmpImg = $image.find(this.meta.NSclass + 'icon');
          parent = tmpImg.parent().get(0);
          tmpImg.remove();
          tmp = new Image();
          $(tmp).one('load', (function(_this) {
            return function() {
              drawing.setImage(_this.data[item], tmp, parent);
              return tmp = null;
            };
          })(this));
          tmp.src = this.data[item].src;
      }
      models[this.gridId].data[item].image = $image;
    };


    /**
     *
     * @method _showImages
     * @private
     *
     * 'shows' items witch are not in view
     * 
     * is not used
     */

    Row.prototype._showImages = function() {
      if (this.rowData.inView) {
        return;
      }
      _.each(this.rowData.images, (function(_this) {
        return function(item) {
          _this._showImage(item);
        };
      })(this));
      this.rowData.inView = true;
    };

    return Row;

  })();


  /**
   *
   * @class MMG.View.Image
   *
   * is used to create a markup for the item
   */

  MMG.View.Image = (function() {
    var Models, Template;

    Models = MMG.Data.Models;

    Template = MMG.View.Template;


    /**
     *
     * @constructor
     * @param {String} gridId
     * @param {Integer} itemId
     *
     */

    function Image(gridId1, itemId) {
      this.gridId = gridId1;
      this.itemId = itemId;
      this._registerImage = bind(this._registerImage, this);
      this._createImage = bind(this._createImage, this);
      this._useTemplate = bind(this._useTemplate, this);
      this.model = Models[this.gridId];
      this.data = this.model.data[this.itemId];
      this.type = this.data.type;
      this.meta = this.model.meta;
      this._string = '';
      this.image = null;
      this._useTemplate();
      this._createImage();
      this._registerImage();
    }


    /**
     *
     * @method _useTemplate
     * @private
     *
     * builds a string from the template
     */

    Image.prototype._useTemplate = function() {
      var compiled, templateName;
      templateName = this.meta.templateName;
      if (this.type) {
        templateName = this.type;
      }
      compiled = Template.getTemplate(this.gridId, templateName).getCompiled();
      this._string = compiled({
        meta: this.meta,
        data: this.data,
        imageId: this.itemId
      });
    };


    /**
     *
     * @method _createImage
     * @private
     *
     * creates a markup
     */

    Image.prototype._createImage = function() {
      this.image = $(this._string);
    };


    /**
     *
     * @method _registerImage
     * @private
     *
     */

    Image.prototype._registerImage = function() {
      this.data.image = this.image;
    };

    return Image;

  })();


  /**
   *
   * @class MMG.Utility.Parser
   *
   */

  MMG.Utility.Parser = (function() {

    /*
    the Singleton Pattern is used
     */
    var Models, PrivateClass, instance;

    function Parser() {}

    instance = {};

    Models = MMG.Data.Models;


    /**
     * @method getParser
     * @param {String} gridId
     * @public
     * a static method that is used to call the Parser instance
     */

    Parser.getParser = function(gridId) {
      return instance[gridId] != null ? instance[gridId] : instance[gridId] = new PrivateClass(gridId);
    };


    /**
     *
     * @class PrivateClass
     *
     */

    PrivateClass = (function() {

      /**
       * @constructor
       * @param {String} gridId
       */
      function PrivateClass(gridId1) {
        this.gridId = gridId1;
        this._applyParser = bind(this._applyParser, this);
        this.ajax = bind(this.ajax, this);
        this.parse = bind(this.parse, this);
        this.model = Models[this.gridId];
        this.meta = this.model.meta;
        this.data = this.model.data;
        this.NS = this.model.meta.NS;
        this["default"] = 'core';
        this.callback = this.model.meta.parser;
      }


      /**
       *
       * @method parse
       * @public
       *
       */

      PrivateClass.prototype.parse = function() {
        if (_.isFunction(this.callback)) {
          return this._applyParser();
        } else {
          return console.log('the parser must be of function type!');
        }
      };


      /**
       *
       * @method ajax
       * @public
       *
       */

      PrivateClass.prototype.ajax = function(fragment) {
        if (_.isFunction(this.callback)) {
          return this._applyParser(fragment);
        } else {
          return console.log('the parser must be of function type!');
        }
      };


      /**
       *
       * @method _applyParser
       * @private
       * calls the parser function
       */

      PrivateClass.prototype._applyParser = function(root) {
        if (root == null) {
          root = this.meta.root;
        }
        return this.callback.call(this, root);
      };

      return PrivateClass;

    })();

    return Parser;

  })();


  /**
   *
   * @class MMG.Utility.ImageLoader
   *
   */

  MMG.Utility.ImageLoader = (function() {
    var self;

    function ImageLoader() {}

    self = ImageLoader;


    /**
     *
     * @method loadPics
     * @public
     * @static
     * @return {jQuery.Defered}
     *
     * loads images
     *
     */

    ImageLoader.loadPics = function() {
      var data, loaded, loader, loads, t;
      loaded = $.Deferred();
      data = this.data;
      loader = this.meta.loader;
      loader.refresh();
      loader.loading = data != null ? data.length : void 0;
      loader.rate = 5;
      t = this;
      if (data.length === 0) {
        loader.rate = 100;
        loader.end = true;
        loaded.resolve();
        return loaded;
      }
      loads = _.map(data, function(element, i) {
        var image, imageLoaded, src;
        src = element.src;
        image = new Image();
        imageLoaded = $.Deferred();
        $(image).one('load', function() {
          var h, w;
          w = data[i].width = $(this).naturalWidth();
          h = data[i].height = $(this).naturalHeight();
          data[i].ratio = w / h;
          loader.loaded++;
          if (loader.loading !== 0) {
            loader.rate = 5 + Math.ceil(loader.loaded / loader.loading * 95);
          }
          imageLoaded.resolve();
        });
        image.src = data[i].src = self._replaceForRetina.call(t, src);
        _.delay((function() {
          if (!image.complete) {
            image.src = '';
            imageLoaded.resolve();
          }
        }), t.model.meta.maxWait);
        return imageLoaded;
      });
      $.when.apply(null, loads).done(function() {
        loader.end = true;
        loaded.resolve();
      });
      return loaded;
    };


    /**
     *
     * @method _replaceForRetina
     * @private
     * @static
     * @param {String} src
     *
     * inserts Retina suffix if necessary
     *
     */

    ImageLoader._replaceForRetina = function(src) {
      var match, meta, replaceSuffix;
      meta = this.model.meta;
      if (meta.retina !== 2 || meta.pixelRatio < 1.5) {
        return src;
      }
      if (src.indexOf(meta.retinaSuffix + '.') >= 0) {
        return src;
      }
      match = src.match(meta.regexMatch);
      replaceSuffix = meta.retinaSuffix + match[0];
      return src.replace(meta.regexMatch, replaceSuffix);
    };

    return ImageLoader;

  })();


  /**
   *
   * @class MMG.View.View
   *
   */

  MMG.View.View = (function() {
    var Drawing, DrawingSVG, Img, Queue, QueueSimple, Row, models, rows;

    models = MMG.Data.Models;

    Img = MMG.View.Image;

    Row = MMG.View.Row;

    rows = MMG.Data.Rows;

    Drawing = MMG.Drawing.Drawing;

    DrawingSVG = MMG.Drawing.DrawingSVG;

    Queue = MMG.Utility.QueueSingleton;

    QueueSimple = MMG.Utility.QueueSimple;


    /**
     *
     * @constructor
     * @param {String} gridId
     *
     */

    function View(gridId1) {
      this.gridId = gridId1;
      this._getClass = bind(this._getClass, this);
      this._showImage = bind(this._showImage, this);
      this._showImages = bind(this._showImages, this);
      this._hideImages = bind(this._hideImages, this);
      this._scroll = bind(this._scroll, this);
      this._resize = bind(this._resize, this);
      this._setEvents = bind(this._setEvents, this);
      this.add = bind(this.add, this);
      this._buildView = bind(this._buildView, this);
      this._setMinHeight = bind(this._setMinHeight, this);
      this._appendImage = bind(this._appendImage, this);
      this._setMeta = bind(this._setMeta, this);
      this._registerRows = bind(this._registerRows, this);
      this.model = models[this.gridId];
      this.data = this.model.data;
      this.meta = this.model.meta;
      this.queue = Queue.getQueue(this.gridId);
      this.queueSimple = QueueSimple.getQueue(this.gridId);
      this._registerRows();
      this._setMeta();
      this._buildView();
      this._setEvents();
    }


    /**
     *
     * @method _registerRows
     * @private
     *
     */

    View.prototype._registerRows = function() {
      rows[this.gridId] = {
        data: [],
        meta: {},
        built: $.Deferred()
      };
      this.rowMeta = rows[this.gridId].meta;
      this.rowData = rows[this.gridId].data;
    };


    /**
     *
     * @method _setMeta
     * @private
     *
     */

    View.prototype._setMeta = function() {
      var meta;
      meta = {};
      meta.scrollTop = $(document).scrollTop();
      meta.scrollLeft = $(document).scrollLeft();
      rows[this.gridId].meta = meta;
    };


    /**
     *
     * @method _appendImage
     * @private
     * @param {MMG.View.Row} row
     * @param {Integer} i
     * @param {Object} item
     *
     */

    View.prototype._appendImage = function(row, i, item) {
      var image;
      image = new Img(this.gridId, i);
      image.image.appendTo(row.row).css({
        'margin-right': this.meta.margin + 'px'
      });
      row.registerImage(i);
      row.calculate(item);
    };


    /**
     *
     * @method _needNewRow
     * @private
     * @param {MMG.View.Row} row
     * @return {Boolean}
     */

    View.prototype._needNewRow = function(row) {
      if (!row) {
        return true;
      }
      return row.needNew();
    };


    /**
     *
     * @method _setMinHeight
     * @private
     * @param {Object} data 
     *
     *
     */

    View.prototype._setMinHeight = function(data) {
      this.meta.minHeight = _.min(_.pluck(data, 'height'));
      if (this.meta.retina === 1 || (this.meta.retina === 2 && this.meta.pixelRatio > 1.5)) {
        this.meta.minHeight = this.meta.minHeight / 2;
      }
      if (this.meta.rowHeight && this.meta.rowHeight < this.meta.minHeight) {
        this.meta.minHeight = this.meta.rowHeight;
      }
    };


    /**
     *
     * @method _buildView
     * @private
     * @param {Integer} index
     *
     * appends new rows into the grid
     */

    View.prototype._buildView = function(index) {
      var data, fragment, needNewRow, root, row, self;
      fragment = $(document.createDocumentFragment());
      needNewRow = true;
      row = null;
      root = this.meta.root;
      if (index == null) {
        data = this.data;
        index = 0;
      } else {
        data = this.data.slice(index);
      }
      this._setMinHeight(data);
      _.reduce(data, function(memo, item, i, list) {
        if (this._needNewRow(row)) {
          if (row != null) {
            row.resize();
          }
          row = new Row(this.gridId);
          row.row.appendTo(memo);
        }
        this._appendImage(row, i + index, item);
        if (list.length === i + 1) {
          row.rowData.finished = false;
          row.resize();
        }
        return memo;
      }, fragment, this);
      this.meta.root.trigger('dataLoaded', {
        all: this.data
      });
      self = this;

      /*
      if some filters specified:
       */
      switch (false) {
        case !this.meta.useCanvas:
          _.each(data, function(item, i) {
            var tmpImg;
            if (item.image) {
              tmpImg = item.image.find(self.meta.NSclass + 'icon');
              self.queueSimple.execute(_.bind(function(grid, tmp) {
                new Drawing(grid, tmp);
              }, self, self.gridId, tmpImg.get(0)));
            }
          });
          break;
        case !this.meta.SVGFilter:
          _.each(data, function(item, i) {
            var parent, tmpImg;
            if (item.image) {
              tmpImg = item.image.find(self.meta.NSclass + 'icon');
              parent = tmpImg.parent().get(0);
              if (!self.meta.twin) {
                tmpImg.remove();
              }
              self.queueSimple.execute(_.bind(function(grid, i, p) {
                new DrawingSVG(grid, i, p);
              }, self, self.gridId, item, parent));
            }
          });
          break;
        case !this.meta.ieFilter:
          _.each(data, function(item, i) {
            var twin;
            if (item.image) {
              if (self.meta.twin) {
                twin = $("<img src='" + item.src + "' class='" + self.meta.NS + "-filtered'>");
                $(self.meta.NSclass + 'icon', item.image.get(0)).after(twin);
                twin.css({
                  height: item.newHeight + 'px',
                  width: item.newWidth + 'px'
                });
              } else {
                $(self.meta.NSclass + 'icon', item.image.get(0)).addClass(self.meta.NS + '-filtered');
              }
            }
          });
          break;
        case !this.meta.forcedTwin:
          _.each(data, function(item, i) {
            var twin;
            if (item.image) {
              twin = $("<img src='" + item.src + "' class='" + self.meta.NS + "-filtered'>");
              $(self.meta.NSclass + 'icon', item.image.get(0)).after(twin);
              twin.css({
                height: item.newHeight + 'px',
                width: item.newWidth + 'px'
              });
            }
          });
      }
      root.width(root.width() - 1);
      root.append(fragment).css({
        visibility: 'visible'
      });
      root.width(root.width() + 1);
      this.meta.root.trigger('afterLoad', {
        all: this.data
      });
      this.meta.root.height('auto');
    };


    /**
     *
     * @method add
     * @public
     * @param {Object} data
     *
     * adds new rows
     *
     */

    View.prototype.add = function(data) {
      var row, self, startIndex;
      row = _.last(rows[this.gridId].data);
      startIndex = this.data.length;
      if (!(this.data.length === 0 || row.finished)) {
        startIndex = row.images[0];
        self = this;
        row.row.remove();
        rows[this.gridId].data.pop();
      }
      models[this.gridId].data = this.data = this.data.concat(data);
      models[this.gridId].meta = this.meta;
      this._buildView(startIndex);
    };


    /**
     *
     * @method _setEvents
     * @private
     *
     */

    View.prototype._setEvents = function() {
      $(window).resize(this._resize);
      if (this.meta.isMobile) {
        $(document).on('scroll', this._scroll);
      } else {
        $(document).on('scrollstop', this._scroll);
      }
    };


    /**
     *
     * @method _resize
     * @private
     *
     */

    View.prototype._resize = function() {
      var w;
      w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
      if ((Math.abs(w - this.meta.winWidth)) < 12) {
        return;
      }
      this.meta.root.empty();
      this.meta.winWidth = w;
      this.meta.winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      this.meta.root.width('auto');
      this._registerRows();
      this._buildView();
    };


    /**
     *
     * @method _scroll
     * @private
     *
     */

    View.prototype._scroll = function() {
      var shift, top;
      if (this.meta.scrollStop) {
        return;
      }
      top = $(document).scrollTop();
      shift = this.rowMeta.scrollTop - top;
      if (Math.abs(shift) < this.meta.winHeight / this.meta.scrollDelta) {
        return;
      }
      this.rowMeta.scrollTop = top;
      this.rowMeta.scrollLeft = $(document).scrollLeft();
      this.meta.scrollStop = true;
      _.each(this.rowData, (function(_this) {
        return function(item, i) {
          if (Row.isRowInView(item, _this.meta, _this.rowMeta)) {
            _this._showImages(item);
          } else {
            _this._hideImages(item);
          }
        };
      })(this));
      this.meta.scrollStop = false;
    };


    /**
     *
     * @method _hideImages
     * @private
     * @param {MMG.View.Row} row
     *
     * hides rows witch are not in view
     */

    View.prototype._hideImages = function(row) {
      if (!row.inView) {
        return;
      }
      _.each(row.images, (function(_this) {
        return function(item) {
          var image;
          image = models[_this.gridId].data[item].image;
          if (image != null) {
            image.remove();
          }
          image = null;
          delete models[_this.gridId].data[item].image;
          return false;
        };
      })(this));
      row.inView = false;
    };


    /**
     *
     * @method _showImages
     * @private
     * @param {MMG.View.Row} row
     *
     * show rows witch are in view
     */

    View.prototype._showImages = function(row) {
      if (row.inView) {
        return;
      }
      row.inView = true;
      _.each(row.images, (function(_this) {
        return function(item) {
          _this.queue.execute([_.bind(_this._showImage, _this, item, row), row]);
        };
      })(this));
    };


    /**
     *
     * @method _showImage
     * @private
     * @param {MMG.View.Row} row
     *
     * show rows that is in view
     */

    View.prototype._showImage = function(item, row) {
      var $image, drawing, image, parent, sizeClass, tmpImg, twin;
      image = new Img(this.gridId, item);
      $image = image.image.appendTo(row.row).css({
        'margin-right': this.meta.margin + 'px',
        height: this.data[item].newHeight + 'px',
        width: this.data[item].newWidth + 'px'
      });
      sizeClass = this._getClass(this.data[item].newWidth);
      if (sizeClass != null) {
        $image.addClass(sizeClass);
      }
      $(this.meta.NSclass + 'fs', $image.get(0)).css({
        height: this.data[item].newHeight + 'px',
        width: this.data[item].newWidth + 'px'
      });
      switch (false) {
        case !this.meta.useCanvas:
          tmpImg = $image.find(this.meta.NSclass + 'icon');
          new Drawing(this.gridId, tmpImg.get(0));
          break;
        case !this.meta.SVGFilter:
          tmpImg = $image.find(this.meta.NSclass + 'icon');
          parent = tmpImg.parent().get(0);
          if (!this.meta.twin) {
            tmpImg.remove();
          }
          drawing = new DrawingSVG(this.gridId, this.data[item], parent);
          break;
        case !this.meta.ieFilter:
          if (this.meta.twin) {
            twin = $("<img src='" + this.data[item].src + "' class='" + this.meta.NS + "-filtered'>");
            $(this.meta.NSclass + 'icon', $image.get(0)).after(twin);
            twin.css({
              height: this.data[item].newHeight + 'px',
              width: this.data[item].newWidth + 'px'
            });
          } else {
            $(this.meta.NSclass + 'icon', $image.get(0)).addClass(this.meta.NS + '-filtered');
          }
          break;
        case !this.meta.forcedTwin:
          twin = $("<img src='" + this.data[item].src + "' class='" + this.meta.NS + "-filtered'>");
          $(this.meta.NSclass + 'icon', $image.get(0)).after(twin);
          twin.css({
            height: this.data[item].newHeight + 'px',
            width: this.data[item].newWidth + 'px'
          });
      }
      models[this.gridId].data[item].image = $image;
    };


    /**
     *
     * @method _getClass
     * @private
     * @param {Integer} width
     *
     * specifies a 'size class': 
     * 'mmg-small' or 'mmg-middle' or undefined
     */

    View.prototype._getClass = function(width) {
      var res;
      res = null;
      switch (false) {
        case !(width <= this.meta.maxSmall):
          res = this.meta.NS + '-small';
          break;
        case !(width <= this.meta.maxMiddle):
          res = this.meta.NS + '-middle';
      }
      return res;
    };

    return View;

  })();


  /**
   *
   * @class MMG.Data.Core
   *
   */

  MMG.Data.Core = (function() {
    var Loader, Models, Parser;

    Models = MMG.Data.Models;

    Loader = MMG.Utility.ImageLoader;

    Parser = MMG.Utility.Parser;


    /**
     *
     * @constructor
     * @param {String} gridId
     *
     */

    function Core(gridId1) {
      this.gridId = gridId1;
      this._html = bind(this._html, this);
      this._data = bind(this._data, this);
      this._ajax = bind(this._ajax, this);
      this._loadPics = bind(this._loadPics, this);
      this._init = bind(this._init, this);
      this.data = [];
      this.model = Models[this.gridId];
      this.meta = this.model.meta;
      this._init();
    }


    /**
     *
     * @method _init
     * @private
     *
     */

    Core.prototype._init = function() {
      this._getData();
    };


    /**
     *
     * @method _loadPics
     * @private
     *
     */

    Core.prototype._loadPics = function() {
      var loaded, self;
      self = this;

      /*
      jQuery Deferred object
       */
      loaded = Loader.loadPics.call(this);

      /*
      max timeout
       */

      /*
       waits until all images are loaded
       if an image is not loaded it is removed
       frome the list
       */
      loaded.then(function() {
        Models[self.gridId].meta = self.meta;
        self.data = _.reject(self.data, function(el) {
          return el.height == null;
        });
        Models[self.gridId].data = self.data;
        Models[self.gridId].built.resolve();
      });
    };


    /**
     *
     * @method _getData
     * @private
     * factory function
     */

    Core.prototype._getData = function() {
      switch (false) {
        case !this.model.meta.data:
          this._data();
          break;
        case !this.model.meta.url:
          this._ajax();
          break;
        default:
          this._html();
      }
    };


    /**
     *
     * @method _ajax
     * @private
     * if by ajax
     */

    Core.prototype._ajax = function() {
      var self;
      self = this;
      $.getJSON(this.model.meta.url, function(inData) {
        var data;
        if (self.meta.jsonParser) {
          if (!_.isFunction(self.meta.jsonParser)) {
            console.error('jsonParser must be a function');
            self.data = {};
            return;
          } else {
            data = self.meta.jsonParser(inData);
          }
        } else {
          data = inData;
        }
        if (data[0].src) {
          self.data = data;
        } else {
          self.data = data[0];
          if (data[1]) {
            self.meta.lastLoadedMeta = data[1];
          }
        }
        self._loadPics();
      });
    };


    /**
     *
     * @method _data
     * @private
     * if Object
     */

    Core.prototype._data = function() {
      this.data = this.model.meta.data;
      this._loadPics();
    };


    /**
     *
     * @method _html
     * @private
     * if markup
     */

    Core.prototype._html = function() {
      var parser;
      parser = Parser.getParser(this.gridId);
      this.data = parser.parse();
      this._loadPics();
    };

    return Core;

  })();


  /**
   *
   * the set of default options
   *
   */

  MMG.Grid.def = {
    onInitCallback: function() {},
    afterInitCallback: function() {},
    onAjaxCallback: function() {},
    afterAjaxCallback: function() {},
    insertInImgBeforeCallback: function() {},
    insertInImgCallback: function() {},
    NS: 'mmg',
    NSclass: '.mmg-',
    NSevent: '.mmg',
    regexMatch: /\.[\w\?=]+$/,
    retinaSuffix: '@2x',
    margin: 2,
    retina: 0,
    maxWait: 5000,
    maxSmall: 180,
    maxMiddle: 400,
    useCanvas: false,
    pixelRatio: 1,
    filters: null,
    SVGFilter: false,
    kVisible: 3,
    scrollDelta: 1.1,
    stop: false,
    scrollStop: false,
    waitCount: 0,
    isMobile: false,
    rowWidth: 0,
    elementsArray: [],
    top: 0,
    supportSVGFilters: true,
    rowsTop: [],
    onViewRowsLength: 0,
    lightbox: {},
    oldIEFilter: 'none'
  };


  /**
   *
   * MMG.Lightbox.setSwipe
   *
   * @param {String} name - the name of the swipe presetting
   * @container {HTML element} - the container of the swipe
   * @data {Array} - the data object
   * @options {Object} - user settings
   *
   * a factory fanction
   *
   * @return {MMG.Lightbox.Swipe}
   *
   *
   */

  MMG.Lightbox.setSwipe = function(name, container, data, options) {

    /*
    vertical
     */
    var swipeClassica, swipeMinimal, swipeSimple, swipeUntitled, swipeVertical;
    swipeVertical = function(container, data, options) {
      var defaults, dimentions, settings;
      dimentions = function() {
        var $container, $left, $right, $root, $swipe, winHeight, winWidth;
        $container = $(this.container);
        winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
        $container.width(winWidth).height(winHeight).addClass('swipe-vertical');
        $root = $container.children('.swipe-container');
        $swipe = $root.children('.swipe');
        $left = $root.children('.swipe-left-controlls');
        $right = $root.children('.swipe-right-controlls');
        $swipe.width(winWidth - $right.width() - $left.width());
        $swipe.height(winHeight);
        $right.height(winHeight);
        $left.height(winHeight);
      };
      defaults = {
        swipeTemplate: "<div class='swipe-container'><div class='swipe-indicator-container'></div><div class='swipe-left-controlls'><div class='swipe-title-container'><div class='swipe-title'></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-right-controlls'><div class='swipe-ui hidden'><div class='swipe-close'><span class='swipe-icon-cross'></span></div><div class='swipe-buttons'><div class='swipe-left'><span class='swipe-icon-left'></span></div><div class='swipe-show swipe-play'><span></span></div><div class='swipe-right'><span class='swipe-icon-right'></span></div></div></div></div></div>",
        onMadeSwipe: dimentions,
        parser: function(data) {
          return _.map(data, function(item) {
            var ref;
            return {
              href: item.href,
              title: ((ref = item.lb) != null ? ref.title : void 0) || item.title
            };
          });
        },
        onResize: dimentions,
        makeUI: function() {
          var that;
          that = this;
          $(this.container).find('.swipe-right').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.next();
            };
          })(this));
          $(this.container).find('.swipe-left').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.prev();
            };
          })(this));
          $(this.container).find('.swipe-play').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.toggle();
            };
          })(this));
          $(this.container).find('.swipe-close').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.close();
            };
          })(this));
        },
        makeContent: function() {
          var $container, $title, char, fr, item, j, len1, ref;
          item = this.data[this.index];
          $container = $(this.container);
          fr = document.createDocumentFragment();
          if (item.title) {
            ref = item.title.split('');
            for (j = 0, len1 = ref.length; j < len1; j++) {
              char = ref[j];
              $("<div>" + char + "</div>").appendTo(fr);
            }
          }
          $title = $container.find('.swipe-title-container').css({
            height: item.height,
            width: '100%',
            top: item.top,
            left: item.left
          }).removeClass('hidden').children('.swipe-title').empty().append(fr);
          $container.find('.swipe-ui').css({
            height: item.height,
            width: '100%',
            top: item.top,
            right: item.left
          }).removeClass('hidden');
        },
        onClose: function() {
          var $container;
          $container = $(this.container);
          $container.find('.swipe-title-container').addClass('hidden');
          $container.find('.swipe-ui').addClass('hidden');
          $container.find('.swipe-indicator-container').css('visibility', 'hidden').empty();
        },
        beforeSlide: function() {
          $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden');
        },
        marginH: 0,
        marginV: 3,
        indicator: true,
        indicatorStart: function() {
          var $container, $img, $indicator, rect, that;
          $indicator = $('<div class="swipe-indicator"><div></div></div>');
          $img = $(this.getCurrentSlide()).find('.swipe-center');
          rect = $img[0].getBoundingClientRect();
          $container = $(this.container).find('.swipe-indicator-container').css({
            visibility: 'visible',
            width: rect.width,
            top: rect.top,
            left: rect.left
          });
          $indicator.appendTo($container).children('div').width($(window).width()).height($indicator.height());
          that = this;
          setTimeout((function() {
            $indicator.css({
              'animation-name': 'indicator',
              '-webkit-animation-name': 'indicator',
              'animation-duration': that.delay + 'ms',
              '-webkit-animation-duration': that.delay + 'ms'
            });
          }), 0);
        },
        indicatorStop: function() {
          $(this.container).find('.swipe-indicator-container').css('visibility', 'hidden').empty();
        }
      };
      settings = $.extend(defaults, options);
      return new MMG.Lightbox.Swipe(container, data, settings);
    };

    /*
    classica
     */
    swipeClassica = function(container, data, options) {
      var defaults, dimentions, settings;
      dimentions = function() {
        var $bottom, $container, $root, $swipe, $top, winHeight, winWidth;
        $container = $(this.container);
        winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
        $container.width(winWidth).height(winHeight).addClass('swipe-classica');
        $root = $container.children('.swipe-container');
        $swipe = $root.children('.swipe');
        $top = $root.children('.swipe-top-controlls');
        $bottom = $root.children('.swipe-bottom-controlls');
        $swipe.height(winHeight - $top.height() - $bottom.height());
        $swipe.width(winWidth);
      };
      defaults = {
        swipeTemplate: "<div class='swipe-container'><div class='swipe-indicator-container'></div><div class='swipe-top-controlls'><div class='swipe-title-container'><div class='swipe-title'></div><div class='swipe-close'><span class='swipe-icon-cross'></span></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-bottom-controlls'><div class='swipe-ui hidden'><div class='swipe-left'><span class='swipe-icon-left'></span></div><div class='swipe-show swipe-play'><span></span></div><div class='swipe-right'><span class='swipe-icon-right'></span></div><div class='swipe-counter'></div></div></div></div>",
        onMadeSwipe: dimentions,
        parser: function(data) {
          return _.map(data, function(item) {
            var ref;
            return {
              href: item.href,
              title: ((ref = item.lb) != null ? ref.title : void 0) || item.title
            };
          });
        },
        onResize: dimentions,
        makeUI: function() {
          var that;
          that = this;
          $(this.container).find('.swipe-right').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.next();
            };
          })(this));
          $(this.container).find('.swipe-left').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.prev();
            };
          })(this));
          $(this.container).find('.swipe-play').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.toggle();
            };
          })(this));
          $(this.container).find('.swipe-close').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.close();
            };
          })(this));
        },
        makeContent: function() {
          var $container, $title, item;
          $container = $(this.container);
          $title = $container.find('.swipe-title-container');
          item = this.data[this.index];
          $title.width(item.width).removeClass('hidden').children('.swipe-title').html(item.title);
          $container.find('.swipe-ui').width(item.width).removeClass('hidden');
          return $container.find('.swipe-counter').html(this.index + 1 + ' / ' + this.length);
        },
        onClose: function() {
          var $container;
          $container = $(this.container);
          $container.find('.swipe-title-container').addClass('hidden');
          $container.find('.swipe-ui').addClass('hidden');
          $container.find('.swipe-indicator-container').css('visibility', 'hidden').empty();
        },
        beforeSlide: function() {
          $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden');
        },
        indicator: true,
        indicatorStart: function() {
          var $container, $img, $indicator, rect, that;
          $indicator = $('<div class="swipe-indicator"><div></div></div>');
          $img = $(this.getCurrentSlide()).find('.swipe-center');
          rect = $img[0].getBoundingClientRect();
          $container = $(this.container).find('.swipe-indicator-container').css({
            visibility: 'visible',
            width: rect.width,
            top: rect.top,
            left: rect.left
          });
          $indicator.appendTo($container).children('div').width($(window).width()).height($indicator.height());
          that = this;
          setTimeout((function() {
            $indicator.css({
              'animation-name': 'indicator',
              '-webkit-animation-name': 'indicator',
              'animation-duration': that.delay + 'ms',
              '-webkit-animation-duration': that.delay + 'ms'
            });
          }), 0);
        },
        indicatorStop: function() {
          $(this.container).find('.swipe-indicator-container').css('visibility', 'hidden').empty();
        }
      };
      settings = $.extend(defaults, options);
      return new MMG.Lightbox.Swipe(container, data, settings);
    };

    /*
    untitled
     */
    swipeUntitled = function(container, data, options) {
      var defaults, dimentions, settings;
      dimentions = function() {
        var $bottom, $container, $root, $swipe, $top, winHeight, winWidth;
        $container = $(this.container);
        winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
        $container.width(winWidth).height(winHeight).addClass('swipe-classica');
        $root = $container.children('.swipe-container');
        $swipe = $root.children('.swipe');
        $top = $root.children('.swipe-top-controlls');
        $bottom = $root.children('.swipe-bottom-controlls');
        $swipe.height(winHeight - $top.height() - $bottom.height());
        $swipe.width(winWidth);
      };
      defaults = {
        swipeTemplate: "<div class='swipe-container'><div class='swipe-indicator-container'></div><div class='swipe-top-controlls'><div class='swipe-title-container'><div class='swipe-close'><span class='swipe-icon-cross'></span></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-bottom-controlls'><div class='swipe-ui hidden'><div class='swipe-left'><span class='swipe-icon-left'></span></div><div class='swipe-show swipe-play'><span></span></div><div class='swipe-right'><span class='swipe-icon-right'></span></div><div class='swipe-counter'></div></div></div></div>",
        onMadeSwipe: dimentions,
        parser: function(data) {
          return _.map(data, function(item) {
            var ref, ref1;
            return {
              href: item.href,
              title: ((ref = item.lb) != null ? ref.title : void 0) || item.title,
              description: ((ref1 = item.lb) != null ? ref1.description : void 0) || item.description
            };
          });
        },
        onResize: dimentions,
        makeUI: function() {
          var that;
          that = this;
          $(this.container).find('.swipe-right').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.next();
            };
          })(this));
          $(this.container).find('.swipe-left').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.prev();
            };
          })(this));
          $(this.container).find('.swipe-play').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.toggle();
            };
          })(this));
          $(this.container).find('.swipe-close').on('click', (function(_this) {
            return function(event) {
              event.stopPropagation();
              return _this.close();
            };
          })(this));
        },
        makeContent: function() {
          var $container, $title, item;
          $container = $(this.container);
          $title = $container.find('.swipe-title-container');
          item = this.data[this.index];
          $title.width(item.width).removeClass('hidden');
          $container.find('.swipe-ui').width(item.width).removeClass('hidden');
          return $container.find('.swipe-counter').html(this.index + 1 + ' / ' + this.length);
        },
        onClose: function() {
          var $container;
          $container = $(this.container);
          $container.find('.swipe-title-container').addClass('hidden');
          $container.find('.swipe-ui').addClass('hidden');
          $container.find('.swipe-indicator-container').css('visibility', 'hidden').empty();
        },
        beforeSlide: function() {
          $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden');
        },
        indicator: true,
        indicatorStart: function() {
          var $container, $img, $indicator, rect, that;
          $indicator = $('<div class="swipe-indicator"><div></div></div>');
          $img = $(this.getCurrentSlide()).find('.swipe-center');
          rect = $img[0].getBoundingClientRect();
          $container = $(this.container).find('.swipe-indicator-container').css({
            visibility: 'visible',
            width: rect.width,
            top: rect.top,
            left: rect.left
          });
          $indicator.appendTo($container).children('div').width($(window).width()).height($indicator.height());
          that = this;
          setTimeout((function() {
            $indicator.css({
              'animation-name': 'indicator',
              '-webkit-animation-name': 'indicator',
              'animation-duration': that.delay + 'ms',
              '-webkit-animation-duration': that.delay + 'ms'
            });
          }), 0);
        },
        indicatorStop: function() {
          $(this.container).find('.swipe-indicator-container').css('visibility', 'hidden').empty();
        }
      };
      settings = $.extend(defaults, options);
      return new MMG.Lightbox.Swipe(container, data, settings);
    };

    /*
    minimal
     */
    swipeMinimal = function(container, data, options) {
      var defaults, dimentions, settings;
      dimentions = function() {
        var $bottom, $container, $root, $swipe, $top, winHeight, winWidth;
        $container = $(this.container);
        winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
        $container.width(winWidth).height(winHeight).addClass('swipe-classica');
        $root = $container.children('.swipe-container');
        $swipe = $root.children('.swipe');
        $top = $root.children('.swipe-top-controlls');
        $bottom = $root.children('.swipe-bottom-controlls');
        $swipe.height(winHeight - $top.height() - $bottom.height());
        $swipe.width(winWidth);
      };
      defaults = {
        swipeTemplate: "<div class='swipe-container'><div class='swipe-top-controlls'><div class='swipe-title-container'><div class='swipe-title'></div></div></div><div class='swipe'><div class='swipe-wrap'></div></div><div class='swipe-bottom-controlls'><div class='swipe-ui hidden'><div class='swipe-counter'></div></div></div></div></div>",
        onMadeSwipe: dimentions,
        parser: function(data) {
          return _.map(data, function(item) {
            var ref;
            return {
              href: item.href,
              title: ((ref = item.lb) != null ? ref.title : void 0) || item.title
            };
          });
        },
        onResize: dimentions,
        indicator: false,
        onClose: function() {
          var $container;
          $container = $(this.container);
          $container.find('.swipe-title-container').addClass('hidden');
          $container.find('.swipe-ui').addClass('hidden');
        },
        beforeSlide: function() {
          $(this.container).find('.swipe-title-container, .swipe-ui').addClass('hidden');
        },
        makeContent: function() {
          var $container, $title, item;
          $container = $(this.container);
          $title = $container.find('.swipe-title-container');
          item = this.data[this.index];
          $title.width(item.width).removeClass('hidden').children('.swipe-title').html(item.title);
          $container.find('.swipe-ui').width(item.width).removeClass('hidden');
          $container.find('.swipe-counter').html(this.index + 1 + ' / ' + this.length);
        }
      };
      settings = $.extend(defaults, options);
      return new MMG.Lightbox.Swipe(container, data, settings);
    };

    /*
    simple
     */
    swipeSimple = function(container, data, options) {
      var defaults, dimentions, settings;
      dimentions = function() {
        var $container, winHeight, winWidth;
        $container = $(this.container);
        winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
        $container.width(winWidth).height(winHeight).addClass('swipe-simple');
      };
      defaults = {
        onMadeSwipe: dimentions,
        parser: function(data) {
          return _.map(data, function(item) {
            var ref;
            return {
              href: item.href,
              title: ((ref = item.lb) != null ? ref.title : void 0) || item.title
            };
          });
        },
        onResize: dimentions,
        indicator: false,
        marginH: 3,
        marginV: 3
      };
      settings = $.extend(defaults, options);
      return new MMG.Lightbox.Swipe(container, data, settings);
    };
    if (_.isFunction(name)) {
      return name(container, data, options);
    } else {
      switch (name) {
        case 'classica':
          return swipeClassica(container, data, options);
        case 'untitled':
          return swipeUntitled(container, data, options);
        case 'minimal':
          return swipeMinimal(container, data, options);
        case 'simple':
          return swipeSimple(container, data, options);
        case 'vertical':
          return swipeVertical(container, data, options);
        default:
          return swipeClassica(container, data, options);
      }
    }
  };


  /**
   *
   * @class MMG.Lightbox.LightboxSwipe
   *
   */

  MMG.Lightbox.Swipe = (function() {

    /**
     *
     * @constructor
     * @container {HTML element} - the container of the swipe
     * @data {Array} - the data object
     * @options {Object} - user settings
     *
     */
    function Swipe(container1, data, options) {
      this.container = container1;
      if (options == null) {
        options = {};
      }
      this._showCaptions = bind(this._showCaptions, this);
      this._hideAfter = bind(this._hideAfter, this);
      this.getMargins = bind(this.getMargins, this);
      this.getRect = bind(this.getRect, this);
      this.toggle = bind(this.toggle, this);
      this.stop = bind(this.stop, this);
      this.play = bind(this.play, this);
      this.next = bind(this.next, this);
      this.prev = bind(this.prev, this);
      this.last = bind(this.last, this);
      this.first = bind(this.first, this);
      this.go = bind(this.go, this);
      this._onClick = bind(this._onClick, this);
      this._onkeydown = bind(this._onkeydown, this);
      this._next = bind(this._next, this);
      this._prev = bind(this._prev, this);
      this._resize = bind(this._resize, this);
      this._setNaturalSize();
      this.parser = options.parser || this._identity;
      this.data = this._parseData(data);
      this._init(options);
    }


    /**
     *
     * @method _noop
     * @private
     *
     */

    Swipe.prototype._noop = function() {};


    /**
     *
     * @method _identity
     * @param {Any} v 
     * @return {Any}
     * @private
     *
     */

    Swipe.prototype._identity = function(v) {
      return v;
    };


    /**
     *
     * @method _offloadFn
     * @param {Function} fn - the function that must be executed
     * @private
     *
     */

    Swipe.prototype._offloadFn = function(fn) {
      setTimeout(fn || this._noop, 0);
    };


    /**
     *
     * @method _parseData
     * @private
     * @param {Array} data - the data object
     *
     */

    Swipe.prototype._parseData = function(data) {
      return this.parser(data);
    };


    /**
     *
     * @method _init
     * @private
     * @param {Object} options
     *
     */

    Swipe.prototype._init = function(options) {
      if (!this.container) {
        throw new Error('You must define a container element');
      }
      this.browser = {
        addEventListener: !!window.addEventListener,
        touch: 'ontouchstart' in window,
        transitions: (function(temp) {
          var i, props;
          props = ['transitionProperty', 'WebkitTransition', 'MozTransition', 'OTransition', 'msTransition'];
          for (i in props) {
            if (temp.style[props[i]] !== void 0) {
              return true;
            }
          }
          return false;
        })(document.createElement('swipe'))
      };
      this.index = parseInt(options.startSlide, 10) || 0;
      this.speed = options.speed || 400;
      this.continuous = options.continuous !== void 0 ? options.continuous : true;
      this.transitionEnd = options.transitionEnd;
      this.delay = 0;
      this.indicator = options.indicator || false;
      this.showDelay = options.delay || 4000;
      this.auto = options.auto;
      if (this.auto) {
        this.delay = this.showDelay;
      }
      this.stopPropagation = options.stopPropagation;
      this.disableScroll = options.disableScroll;
      this.closeOnEnd = options.closeOnEnd;
      this.enableClick = options.enableClick;
      if (this.enableClick == null) {
        this.enableClick = true;
      }
      this.enableWheel = options.enableWheel;
      if (this.enableWheel == null) {
        this.enableWheel = true;
      }
      this.swipeClass = options.swipeClass || 'swipe';
      this.swipeWrapClass = options.swipeWrapClass || 'swipe-wrap';
      this.slideClass = options.slideClass || 'slide';
      this.playClass = options.playClass || 'swipe-play';
      this.stopClass = options.stopClass || 'swipe-stop';
      this.firstClass = options.firstClass || 'swipe-first-slide';
      this.lastClass = options.lastClass || 'swipe-last-slide';
      this.captionClass = options.captionClass || 'mmg-lb-caption';
      this.lightbox = options.lightbox || {};
      this.ieVer = this.lightbox.ieVer;
      this.interval = null;
      this.makeUI = options.makeUI || this._noop;
      this.onResize = options.onResize;
      this.makeContent = options.makeContent;
      this.onMadeSwipe = options.onMadeSwipe;
      this.delayedSetup = options.delayedSetup;
      this.beforeSlide = options.beforeSlide;
      this.close = options.close || this._noop;
      this.close = _.wrap(this.close, (function(_this) {
        return function(func) {
          _this.stop();
          func();
        };
      })(this));
      this.onClose = options.onClose || this._noop;
      this.indicatorStart = options.indicatorStart;
      this.indicatorStop = options.indicatorStop;
      this.loaderTemplate = options.loaderTemplate || '<div class="loader"><span class="l1"></span><span class="l2"></span><span class="l3"></span></div>';
      this.resizable = true;
      if (options.resizable !== void 0) {
        this.resizable = options.resizable;
      }
      this.swipeTemplate = options.swipeTemplate;
      if (this.swipeTemplate == null) {
        this.swipeTemplate = "<div class='" + this.swipeClass + "'><div class='" + this.swipeWrapClass + "'></div></div>";
      }
      this.useCaptionTemplate = options.useCaptionTemplate;
      this.captionName = options.captionName;
      this.getCaptionName = options.getCaptionName;
      this.captionHideAfter = options.captionHideAfter;
      this.loadingClass = options.loadingClass || 'loading';
      this.marginH = options.marginH || 5;
      this.marginV = options.marginV || 0;
      this.type = 'image';
      this.images = [];
      this._makeSwipe();
      if (!this.delayedSetup) {
        this._setup();
      }
      this._makeUI();
      if (this.enableClick) {
        $(this.container).on('click', this._onClick);
      }
      if (this.enableWheel) {
        this._getWheel(this.container);
      }
    };


    /**
     *
     * @method _setup
     * @private
     *
     *
     */

    Swipe.prototype._setup = function() {
      var i;
      this._removeAll();
      if (this.auto) {
        this.delay = this.showDelay;
      }
      this.element = $(this.root).children('.' + this.swipeWrapClass).get(0);
      this.slides = this._makeSlides();
      this.length = this.slides.length;
      this.indicatorRun = false;
      this.images = (function() {
        var j, len1, ref, results;
        ref = this.slides;
        results = [];
        for (j = 0, len1 = ref.length; j < len1; j++) {
          i = ref[j];
          results.push(0);
        }
        return results;
      }).call(this);
      this.start = {};
      this.delta = {};
      this.isScrolling = void 0;
      if (this.length < 2) {
        this.continuous = false;
      }
      if (this.browser.transitions && this.continuous && this.length < 3) {
        this.element.appendChild(this.slides[0].cloneNode(true));
        this.element.appendChild(this.element.children[1].cloneNode(true));
        this.slides = this.element.children;
      }
      this.slidePos = [];
      this.width = this.root.getBoundingClientRect().width || this.root.offsetWidth;
      this.element.style.width = (this.length * this.width) + 'px';
      _.each(this.slides, (function(_this) {
        return function(slide, pos) {
          slide.style.width = _this.width + 'px';
          slide.setAttribute('data-index', pos);
          if (_this.browser.transitions) {
            slide.style.left = pos * -_this.width + 'px';
            _this._move(pos, (_this.index > pos ? -_this.width : _this.index < pos ? _this.width : 0), 0);
          }
        };
      })(this));
      if (this.continuous && this.browser.transitions) {
        this._move(this._circle(this.index - 1), -this.width, 0);
        this._move(this._circle(this.index + 1), this.width, 0);
      }
      if (!this.browser.transitions) {
        this.element.style.left = this.index * -this.width + 'px';
      }
      this.root.style.visibility = 'visible';
      this._loadImages(this.index);
      this._addListeners();
      $('body').on('keydown', this._onkeydown);
    };


    /**
     *
     * @method _resize
     * @param {Boolean} active
     * @private
     *
     */

    Swipe.prototype._resize = function(active) {
      var ref;
      if (active == null) {
        active = true;
      }
      if ((ref = this.onResize) != null) {
        ref.call(this);
      }
      if (active) {
        this._setup();
      }
    };


    /**
     *
     * @method _onMadeSwipe
     * @private
     *
     */

    Swipe.prototype._onMadeSwipe = function() {
      var ref;
      if ((ref = this.onMadeSwipe) != null) {
        ref.call(this);
      }
    };


    /**
     *
     * @method _makeSwipe
     * @private
     *
     */

    Swipe.prototype._makeSwipe = function() {
      var $swipe;
      $swipe = $(this.swipeTemplate);
      $swipe.appendTo($(this.container));
      this._onMadeSwipe();
      if ($swipe.hasClass(this.swipeClass)) {
        this.root = $swipe.get(0);
      } else {
        this.root = $swipe.find('.' + this.swipeClass).get(0);
      }
    };


    /**
     *
     * @method _makeContent
     * @private
     *
     */

    Swipe.prototype._makeContent = function() {
      var ref;
      this._addClasses();
      clearTimeout(this.hide);
      this._makeInterval();
      if ((ref = this.makeContent) != null) {
        ref.call(this);
      }
      this._showCaptions();
    };


    /**
     *
     * @method _makeUI
     * @private
     *
     */

    Swipe.prototype._makeUI = function() {
      this.makeUI.call(this);
    };


    /**
     *
     * @method _removeAll
     * @private
     *
     */

    Swipe.prototype._removeAll = function() {
      $(this.root).off();
      $(this.element).empty().off();
      $('body').off('keydown', this._onkeydown);
    };


    /**
     *
     * @method _makeSlides
     * @private
     * @return {Array of HTML-elements}
     *
     */

    Swipe.prototype._makeSlides = function() {
      var item, j, len1, ref, results;
      ref = this.data;
      results = [];
      for (j = 0, len1 = ref.length; j < len1; j++) {
        item = ref[j];
        results.push(this._makeSlide(item));
      }
      return results;
    };


    /**
     *
     * @method _makeSlide
     * @private
     * @param {Object} item
     * @return {HTML-element}
     *
     */

    Swipe.prototype._makeSlide = function(item) {
      return $('<div class="slide"></div>').appendTo($(this.element)).get(0);
    };


    /**
     *
     * @method _isLegalIndex
     * @private
     * @param {Integer} index
     * @return {Boolean}
     *
     */

    Swipe.prototype._isLegalIndex = function(index) {
      var diff, last;
      last = this.length - 1;
      diff = index - this.index;
      if ((-3 < diff && diff < 3)) {
        return true;
      }
      if (!this.continuous) {
        return false;
      }
      if (last - diff + 1 < 3) {
        return true;
      }
      if (last + diff + 1 < 3) {
        return true;
      }
      return false;
    };


    /**
     *
     * @method _unloadImages
     * @private
     *
     */

    Swipe.prototype._unloadImages = function() {
      var i, j, ref;
      for (i = j = 0, ref = this.data.length - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        this._unloadImage(i);
      }
    };


    /**
     *
     * @method _unloadImage
     * @private
     * @param {Integer} index
     *
     */

    Swipe.prototype._unloadImage = function(index) {
      if (this._isLegalIndex(index)) {
        return;
      }
      if (!this.images[index]) {
        return;
      }
      $(this.slides[index]).empty();
      this.images[index] = false;
    };


    /**
     *
     * @method _loadSlide
     * @param {Integer} index
     * @private
     *
     *
     */

    Swipe.prototype._loadSlide = function(index) {
      var type;
      type = this.data[index].type || this.type;
      switch (type) {
        case 'image':
          this._loadImage(index);
      }
    };


    /**
     *
     * @method _makeLoader
     * @private
     * @return {jQuery Object}
     *
     */

    Swipe.prototype._makeLoader = function() {
      return $(this.loaderTemplate);
    };


    /**
     *
     * @method _loadingStart
     * @private
     * @param {Integer} index
     *
     */

    Swipe.prototype._loadingStart = function(index) {
      $(this.slides[index]).addClass(this.loadingClass);
      this._makeLoader().appendTo(this.slides[index]);
    };


    /**
     *
     * @method _loadingStop
     * @private
     * @param {Integer} index
     *
     */

    Swipe.prototype._loadingStop = function(index) {
      $(this.slides[index]).removeClass(this.loadingClass).empty();
    };


    /**
     *
     * @method _loadError
     * @private
     * @param {Integer} index
     *
     */

    Swipe.prototype._loadError = function(index) {
      console.log(event.currentTarget.src + " can't be loaded");
    };


    /**
     *
     * @method _loadImage
     * @private
     * @param {Integer} index
     *
     */

    Swipe.prototype._loadImage = function(index) {
      var bigHeight, bigWidth, data, img, root, self, slides, winHeight, winRatio, winWidth;
      self = this;
      if (!this._isLegalIndex(index)) {
        return;
      }
      if (this.images[index] > 0) {
        return;
      }
      this.images[index] = 1;
      this._loadingStart(index);
      img = new Image();
      root = this.root;
      data = this.data;
      slides = this.slides;
      winHeight = $(root).height();
      winWidth = $(root).width();
      bigWidth = winWidth * (1 - (this.marginH / 50));
      bigHeight = winHeight * (1 - (this.marginV / 50));
      winRatio = bigWidth / bigHeight;
      $(img).on('error', function(event) {
        self.images[index] = 2;
        self._loadingStop(index);
        self._loadError(index);
      });
      $(img).on('load', function() {
        var caption, h, left, newHeight, newWidth, ratio, top, w;
        self.images[index] = 3;
        w = $(this).naturalWidth();
        h = $(this).naturalHeight();
        newHeight = h;
        newWidth = w;
        ratio = w / h;
        if (ratio > winRatio) {
          if (w > bigWidth) {
            newWidth = bigWidth;
            newHeight = newWidth / ratio;
          }
        } else {
          if (h > bigHeight) {
            newHeight = bigHeight;
            newWidth = newHeight * ratio;
          }
        }
        newHeight = Math.round(newHeight);
        newWidth = Math.round(newWidth);
        self._loadingStop(index);
        left = Math.round((winWidth - newWidth) / 2);
        top = Math.round((winHeight - newHeight) / 2);
        caption = self.useCaptionTemplate(self.data, self.captionName, index);
        $(img).wrap('<div class="swipe-center"></div>').parent().append(caption).css({
          left: left,
          top: top,
          width: newWidth,
          height: newHeight
        }).appendTo(slides[index]);
        data[index].width = newWidth;
        data[index].height = newHeight;
        data[index].top = top;
        data[index].left = left;
        if (index === self.index) {
          $(self.root).trigger('loadend');
          self._makeContent();
        }
      });
      img.src = data[index].href;
    };


    /**
     *
     * @method _loadImages
     * @private
     *
     */

    Swipe.prototype._loadImages = function() {
      var i, j, ref;
      this._loadSlide(this.index);
      if (this.index + 1 < this.length) {
        this._loadSlide(this.index + 1);
      }
      if (this.index - 1 >= 0) {
        this._loadSlide(this.index - 1);
      }
      for (i = j = ref = this.data.length - 1; ref <= 0 ? j <= 0 : j >= 0; i = ref <= 0 ? ++j : --j) {
        this._loadSlide(i);
      }
    };


    /**
     *
     * @method _addListeners
     * @private
     *
     */

    Swipe.prototype._addListeners = function() {
      if (this.browser.addEventListener) {
        if (this.browser.touch) {
          this.element.addEventListener('touchstart', this, false);
        }
        if (this.browser.transitions) {
          this.element.addEventListener('webkitTransitionEnd', this, false);
          this.element.addEventListener('msTransitionEnd', this, false);
          this.element.addEventListener('oTransitionEnd', this, false);
          this.element.addEventListener('otransitionend', this, false);
          this.element.addEventListener('transitionend', this, false);
          this.element.addEventListener('mousedown', this, false);
          this.element.addEventListener('mousemove', this, false);
          this.element.addEventListener('mouseup', this, false);
          this.element.addEventListener('mouseout', this, false);
        }
      }
    };


    /**
     *
     * @method _prev
     * @private
     *
     */

    Swipe.prototype._prev = function() {
      if (this.continuous) {
        this._slide(this.index - 1);
      } else if (this.index) {
        this._slide(this.index - 1);
      }
    };


    /**
     *
     * @method _next
     * @private
     *
     */

    Swipe.prototype._next = function() {
      var ref;
      if (this.indicator && this.indicatorRun) {
        if ((ref = this.indicatorStop) != null) {
          ref.call(this);
        }
      }
      this.indicatorRun = false;
      if (this.continuous) {
        this._slide(this.index + 1);
      } else if (this.index < this.length - 1) {
        this._slide(this.index + 1);
      }
    };


    /**
     *
     * @method _circle
     * @param  {Integer} index
     * @return {Integer}
     * @private
     *
     */

    Swipe.prototype._circle = function(index) {
      return (this.length + (index % this.length)) % this.length;
    };


    /**
     *
     * @method _slide
     * @param  {Integer} to
     * @param {Integer} slideSpeed
     * @private
     *
     */

    Swipe.prototype._slide = function(to, slideSpeed) {
      var diff, direction, natural_direction;
      if (this.index === to) {
        return;
      }
      if (this.browser.transitions) {
        direction = Math.abs(this.index - to) / (this.index - to);
        if (this.continuous) {
          natural_direction = direction;
          direction = -this.slidePos[this._circle(to)] / this.width;
          if (direction !== natural_direction) {
            to = -direction * this.length + to;
          }
        }
        diff = Math.abs(this.index - to) - 1;
        while (diff--) {
          this._move(this._circle((to > this.index ? to : this.index) - diff - 1), this.width * direction, 0);
        }
        to = this._circle(to);
        this._move(this.index, this.width * direction, slideSpeed || this.speed);
        this._move(to, 0, slideSpeed || this.speed);
        if (this.continuous) {
          this._move(this._circle(to - direction), -(this.width * direction), 0);
        }
      } else {
        to = this._circle(to);
        this._animate(this.index * -this.width, to * -this.width, slideSpeed || this.speed);
      }
      this._changeIndex(to);
    };


    /**
     *
     * @method _move
     * @param  {Integer} index
     * @param {Integer} dist
     * @param {Integer} speed
     * @private
     *
     */

    Swipe.prototype._move = function(index, dist, speed) {
      this._translate(index, dist, speed);
      this.slidePos[index] = dist;
    };


    /**
     *
     * @method _translate
     * @param  {Integer} index
     * @param {Integer} dist
     * @param {Integer} speed
     * @private
     *
     */

    Swipe.prototype._translate = function(index, dist, speed) {
      var slide, style;
      slide = this.slides[index];
      style = slide != null ? slide.style : void 0;
      if (!style) {
        return;
      }
      style.webkitTransitionDuration = style.MozTransitionDuration = style.msTransitionDuration = style.OTransitionDuration = style.transitionDuration = speed + 'ms';
      style.webkitTransform = 'translate(' + dist + 'px,0)' + 'translateZ(0)';
      style.msTransform = style.MozTransform = style.OTransform = 'translateX(' + dist + 'px)';
    };


    /**
     *
     * @method _animate
     * @param  {Integer} from
     * @param {Integer} to
     * @param {Integer} speed
     * @private
     *
     */

    Swipe.prototype._animate = function(from, to, speed) {
      var start, timer;
      if (!speed) {
        this.element.style.left = to + 'px';
        return;
      }
      start = +(new Date);
      timer = setInterval(((function(_this) {
        return function() {
          var ref, timeElap;
          timeElap = +(new Date) - start;
          if (timeElap > speed) {
            _this.element.style.left = to + 'px';
            if (_this.delay) {
              _this._begin();
            }
            if ((ref = _this.transitionEnd) != null) {
              ref.call(event, _this.index, _this.slides[_this.index]);
            }
            _this._makeContent();
            $(_this.root).trigger('slidemoveend', {
              slide: _this.slides[_this.index],
              data: _this.data[_this.index],
              index: _this.index
            });
            _this._loadImages();
            _this._unloadImages();
            clearInterval(timer);
            return;
          }
          _this.element.style.left = (to - from) * Math.floor(timeElap / speed * 100) / 100 + from + 'px';
        };
      })(this)), 4);
    };


    /**
     *
     * @method handleEvent
     * @param {Event} event
     * @public
     *
     */

    Swipe.prototype.handleEvent = function(event) {
      switch (event.type) {
        case 'mousedown':
          this._onmousedown(event);
          break;
        case 'mousemove':
          this._onmousemove(event);
          break;
        case 'mouseup':
          this._onmouseup(event);
          break;
        case 'mouseout':
          this._onmouseout(event);
          break;
        case 'touchstart':
          this._startHandler(event);
          break;
        case 'touchmove':
          this._moveHandler(event);
          break;
        case 'touchend':
          this._offloadFn(this._endHandler(event));
          break;
        case 'webkitTransitionEnd':
        case 'msTransitionEnd':
        case 'oTransitionEnd':
        case 'otransitionend':
        case 'transitionend':
          this._offloadFn(this._transitionEndHandler(event));
      }
      if (this.stopPropagation) {
        event.stopPropagation();
      }
    };


    /**
     *
     * @method _onmousedown
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._onmousedown = function(event) {
      event.preventDefault();
      (event.originalEvent || event).touches = [
        {
          pageX: event.pageX,
          pageY: event.pageY
        }
      ];
      this._startHandler(event);
    };


    /**
     *
     * @method _onmousemove
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._onmousemove = function(event) {
      if (this.start && this.start.time) {
        (event.originalEvent || event).touches = [
          {
            pageX: event.pageX,
            pageY: event.pageY
          }
        ];
        this._moveHandler(event);
      }
    };


    /**
     *
     * @method _onmouseup
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._onmouseup = function(event) {
      if (this.start) {
        this._endHandler(event);
        delete this.start;
      }
    };


    /**
     *
     * @method _onmouseout
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._onmouseout = function(event) {
      var related, target;
      if (this.start) {
        target = event.target;
        related = event.relatedTarget;
        if (!related || (related !== target && !$.contains(target, related))) {
          this._onmouseup(event);
        }
      }
    };


    /**
     *
     * @method _onkeydown
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._onkeydown = function(event) {
      switch (event.which || event.keyCode) {
        case 37:
          this.prev();
          break;
        case 39:
          this.next();
      }
    };


    /**
     *
     * @method _startHandler
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._startHandler = function(event) {
      var touches;
      touches = event.touches[0];
      this.start = {
        x: touches.pageX,
        y: touches.pageY,
        time: +(new Date)
      };
      this.isScrolling = void 0;
      this.delta = {};
      this.element.addEventListener('touchmove', this, false);
      this.element.addEventListener('touchend', this, false);
    };


    /**
     *
     * @method _moveHandler
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._moveHandler = function(event) {
      var touches;
      if (event.touches.length > 1 || event.scale && event.scale !== 1) {
        return;
      }
      if (this.disableScroll) {
        event.preventDefault();
      }
      touches = event.touches[0];
      this.delta = {
        x: touches.pageX - this.start.x,
        y: touches.pageY - this.start.y
      };
      if (typeof isScrolling === 'undefined') {
        this.isScrolling = !!(this.isScrolling || Math.abs(this.delta.x) < Math.abs(this.delta.y));
      }
      if (!this.isScrolling) {
        event.preventDefault();
        this.stop();
        if (this.continuous) {
          this._translate(this._circle(this.index - 1), this.delta.x + this.slidePos[this._circle(this.index - 1)], 0);
          this._translate(this.index, this.delta.x + this.slidePos[this.index], 0);
          this._translate(this._circle(this.index + 1), this.delta.x + this.slidePos[this._circle(this.index + 1)], 0);
        } else {
          this.delta.x = this.delta.x / (!this.index && this.delta.x > 0 || this.index === this.length - 1 && this.delta.x < 0 ? Math.abs(this.delta.x) / this.width + 1 : 1);
          this._translate(this.index - 1, this.delta.x + this.slidePos[this.index - 1], 0);
          this._translate(this.index, this.delta.x + this.slidePos[this.index], 0);
          this._translate(this.index + 1, this.delta.x + this.slidePos[this.index + 1], 0);
        }
      }
    };


    /**
     *
     * @method _changeIndex
     * @param {Integer} newIndex
     * @private
     *
     */

    Swipe.prototype._changeIndex = function(newIndex) {
      var ref;
      this.index = newIndex;
      if ((ref = this.beforeSlide) != null) {
        ref.call(this);
      }
    };


    /**
     *
     * @method _endHandler
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._endHandler = function(event) {
      var direction, duration, isPastBounds, isValidSlide;
      duration = +(new Date) - this.start.time;
      isValidSlide = Number(duration) < 250 && Math.abs(this.delta.x) > 20 || Math.abs(this.delta.x) > this.width / 2;
      isPastBounds = !this.index && this.delta.x > 0 || this.index === this.slides.length - 1 && this.delta.x < 0;
      if (this.continuous) {
        isPastBounds = false;
      }
      direction = this.delta.x < 0;
      if (!this.isScrolling) {
        if (isValidSlide && !isPastBounds) {
          if (direction) {
            if (this.continuous) {
              this._move(this._circle(this.index - 1), -this.width, 0);
              this._move(this._circle(this.index + 2), this.width, 0);
            } else {
              this._move(this.index - 1, -this.width, 0);
            }
            this._move(this.index, this.slidePos[this.index] - this.width, this.speed);
            this._move(this._circle(this.index + 1), this.slidePos[this._circle(this.index + 1)] - this.width, this.speed);
            this._changeIndex(this._circle(this.index + 1));
          } else {
            if (this.continuous) {
              this._move(this._circle(this.index + 1), this.width, 0);
              this._move(this._circle(this.index - 2), -this.width, 0);
            } else {
              this._move(this.index + 1, this.width, 0);
            }
            this._move(this.index, this.slidePos[this.index] + this.width, this.speed);
            this._move(this._circle(this.index - 1), this.slidePos[this._circle(this.index - 1)] + this.width, this.speed);
            this._changeIndex(this._circle(this.index - 1));
          }
        } else {
          if (this.continuous) {
            this._move(this._circle(this.index - 1), -this.width, this.speed);
            this._move(this.index, 0, this.speed);
            this._move(this._circle(this.index + 1), this.width, this.speed);
          } else {
            this._move(this.index - 1, -this.width, this.speed);
            this._move(this.index, 0, this.speed);
            this._move(this.index + 1, this.width, this.speed);
          }
        }
      }
      this.element.removeEventListener('touchmove', this, false);
      this.element.removeEventListener('touchend', this, false);
    };


    /**
     *
     * @method _transitionEndHandler
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._transitionEndHandler = function(event) {
      var ref;
      if (parseInt(event.target.getAttribute('data-index'), 10) === this.index) {
        if (this.delay) {
          this._begin();
        }
        if ((ref = this.transitionEnd) != null) {
          ref.call(event, this.index, this.slides[this.index]);
        }
        this._makeContent();
        $(this.root).trigger('slidemoveend', {
          slide: this.slides[this.index],
          data: this.data[this.index],
          index: this.index
        });
        this._loadImages();
        this._unloadImages();
      }
    };


    /**
     *
     * @method _onClick
     * @param {Event} event
     * @private
     *
     */

    Swipe.prototype._onClick = function(event) {
      if (this.delta && (Math.abs(this.delta.x) > 20 || Math.abs(this.delta.y) > 20)) {
        delete this.delta;
        return;
      }
      if ($(event.target).is('img') || $(event.target).hasClass(this.captionClass)) {
        this.next();
      } else {
        this.close();
      }
    };


    /**
     *
     * @method _begin
     * @private
     *
     */

    Swipe.prototype._begin = function() {
      var ref, ref1;
      if (!this.continuous && this.isLast()) {
        if (this.closeOnEnd) {
          this.interval = setTimeout(this.close, this.delay);
          if ((ref = this.indicatorStart) != null) {
            ref.call(this);
          }
          if (this.indicatorStart) {
            this.indicatorRun = true;
          }
        } else {
          this.stop();
        }
      } else {
        this.interval = setTimeout(this._next, this.delay);
        if (this.indicator) {
          if ((ref1 = this.indicatorStart) != null) {
            ref1.call(this);
          }
          if (this.indicatorStart) {
            this.indicatorRun = true;
          }
        }
      }
    };


    /**
     *
     * @method _stop
     * @private
     *
     */

    Swipe.prototype._stop = function() {
      this.delay = 0;
      clearTimeout(this.interval);
    };


    /**
     *
     * @method _setNaturalSize
     * @private
     *
     */

    Swipe.prototype._setNaturalSize = function() {
      (function($) {
        var prop, props, setProp;
        props = ['Width', 'Height'];
        prop = void 0;
        setProp = function(natural, prop) {
          $.fn[natural] = natural in new Image ? (function() {
            return this[0][natural];
          }) : (function() {
            var img, node, value;
            node = this[0];
            img = void 0;
            value = void 0;
            if (node.tagName.toLowerCase() === 'img') {
              img = new Image;
              img.src = node.src;
              value = img[prop];
            }
            return value;
          });
        };
        while (prop = props.pop()) {
          setProp('natural' + prop, prop.toLowerCase());
        }
      })(jQuery);
    };


    /**
     *
     * @method setup
     * @public
     *
     */

    Swipe.prototype.setup = function() {
      this._setup();
    };


    /**
     *
     * @method go
     * @public
     * @param {Integer} to
     * @param {Integer} speed
     *
     */

    Swipe.prototype.go = function(to, speed) {
      this.stop();
      this._slide(to, speed);
    };


    /**
     *
     * @method first
     * @public
     *
     */

    Swipe.prototype.first = function() {
      this.stop();
      this._slide(0, this.speed / 2);
    };


    /**
     *
     * @method last
     * @public
     *
     */

    Swipe.prototype.last = function() {
      this.stop();
      this._slide(this.length - 1, this.speed / 2);
    };


    /**
     *
     * @method prev
     * @public
     *
     */

    Swipe.prototype.prev = function() {
      this.stop();
      this._prev();
    };


    /**
     *
     * @method next
     * @public
     *
     */

    Swipe.prototype.next = function() {
      this.stop();
      this._next();
    };


    /**
     *
     * @method getPos
     * @public
     * @return {Integer} - current index
     *
     */

    Swipe.prototype.getPos = function() {
      return this.index;
    };


    /**
     *
     * @method getRoot
     * @public
     * @return {HTML-element} - the root element of the Swipe
     *
     */

    Swipe.prototype.getRoot = function() {
      return this.root;
    };


    /**
     *
     * @method getNumSlides
     * @public
     * @return {Integer} - the number of slides
     *
     */

    Swipe.prototype.getNumSlides = function() {
      return this.length;
    };


    /**
     *
     * @method getStatus
     * @public
     * @return {Integer} - 0, 1, 2, 3
     *
     */

    Swipe.prototype.getStatus = function() {
      return this.images[this.index];
    };


    /**
     *
     * @method getCurrentSlide
     * @public
     * @return {HTML-element}
     *
     */

    Swipe.prototype.getCurrentSlide = function() {
      return this.slides[this.index];
    };


    /**
     *
     * @method getCurrentTitle
     * @public
     * @return {String}
     *
     */

    Swipe.prototype.getCurrentTitle = function() {
      return this.data[this.index].title;
    };


    /**
     *
     * @method getCurrentTitle
     * @public
     * @return {String}
     *
     */

    Swipe.prototype.getCurrentType = function() {
      return this.data[this.index].type;
    };


    /**
     *
     * @method play
     * @public
     *
     */

    Swipe.prototype.play = function() {
      var button;
      this.delay = this.showDelay;
      this._begin();
      button = $(this.container).find('.' + this.playClass);
      if (button) {
        button.removeClass(this.playClass).addClass(this.stopClass);
      }
    };


    /**
     *
     * @method stop
     * @public
     *
     */

    Swipe.prototype.stop = function() {
      var button, ref;
      this._stop();
      if (this.indicator && this.indicatorRun) {
        if ((ref = this.indicatorStop) != null) {
          ref.call(this);
        }
      }
      this.indicatorRun = false;
      button = $(this.container).find('.' + this.stopClass);
      if (button) {
        button.removeClass(this.stopClass).addClass(this.playClass);
      }
    };


    /**
     *
     * @method toggle
     * @public
     *
     */

    Swipe.prototype.toggle = function() {
      if (this.delay) {
        this.stop();
      } else {
        this.play();
      }
    };


    /**
     *
     * @method getRect
     * @public
     * @return {Object}
     *
     */

    Swipe.prototype.getRect = function() {
      return this.root.getBoundingClientRect();
    };


    /**
     *
     * @method getMargins
     * @public
     * @return {Object}
     *
     */

    Swipe.prototype.getMargins = function() {
      return {
        V: this.marginV,
        H: this.marginH
      };
    };


    /**
     *
     * @method setData
     * @public
     * @param {Array} data
     *
     */

    Swipe.prototype.setData = function(data) {
      this.data = this._parseData(data);
    };


    /**
     *
     * @method setIndex
     * @public
     * @param {Integer} index
     *
     */

    Swipe.prototype.setIndex = function(index) {
      this.index = index * 1;
    };


    /**
     *
     * @method resize
     * @public
     * @param {Boolean} active
     *
     */

    Swipe.prototype.resize = function(active) {
      this._resize(active);
    };

    Swipe.prototype._getWheel = function(elem) {
      var _onWheel, onWheel;
      _onWheel = (function(_this) {
        return function(e) {
          var delta;
          e = e || window.event;
          delta = e.deltaY || e.detail || -e.wheelDelta;
          if (delta > 0) {
            if (_this.element.children) {
              _this.next();
            }
          } else if (delta < 0) {
            if (_this.element.children) {
              _this.prev();
            }
          }
          if (e.preventDefault) {
            e.preventDefault();
          } else {
            e.returnValue = false;
          }
        };
      })(this);
      onWheel = _.throttle(_onWheel, 200);
      if (elem.addEventListener) {
        if ('onwheel' in document) {
          elem.addEventListener('wheel', onWheel, false);
        } else if ('onmousewheel' in document) {
          elem.addEventListener('mousewheel', onWheel, false);
        } else {
          elem.addEventListener('MozMousePixelScroll', onWheel, false);
        }
      } else {
        elem.attachEvent('onmousewheel', onWheel);
      }
    };


    /**
     *
     * @method isLast
     * @public
     * @return {Boolean}
     *
     */

    Swipe.prototype.isLast = function() {
      if (!this.continuous) {
        return this.index === this.length - 1;
      } else {
        return false;
      }
    };


    /**
     *
     * @method isFirst
     * @public
     * @return {Boolean}
     *
     */

    Swipe.prototype.isFirst = function() {
      if (!this.continuous) {
        return this.index === 0;
      } else {
        return false;
      }
    };


    /**
     *
     * @method _addClasses
     * @private
     *
     */

    Swipe.prototype._addClasses = function() {
      var $container;
      if (this.continuous) {
        return;
      }
      $container = $(this.container);
      if (this.isLast()) {
        $container.addClass(this.lastClass).removeClass(this.firstClass);
      } else if (this.isFirst()) {
        $container.removeClass(this.lastClass).addClass(this.firstClass);
      } else {
        $container.removeClass(this.lastClass).removeClass(this.firstClass);
      }
    };

    Swipe.prototype._makeInterval = function() {
      if (this.captionHideAfter) {
        this.hide = setTimeout(this._hideAfter, this.captionHideAfter);
      }
    };

    Swipe.prototype._hideAfter = function() {
      var $caption, ref, ref1;
      $caption = $(this.slides[this.index]).find('.mmg-lb-caption');
      if (!((0 < (ref = this.ieVer) && ref < 10))) {
        $caption.removeClass('mmg-lb-show');
      }
      if ((ref1 = this.lightbox.root) != null) {
        ref1.trigger('timeForCaptionHide', $caption.get(0));
      }
    };

    Swipe.prototype._showCaptions = function() {
      var $caption, $container, ref, ref1;
      $container = $(this.container);
      $caption = $(this.slides[this.index]).find('.mmg-lb-caption');
      if (!((0 < (ref = this.ieVer) && ref < 10))) {
        $container.find('.mmg-lb-show').removeClass('mmg-lb-show');
        setTimeout((function() {
          return $caption.addClass('mmg-lb-show');
        }), 0);
      }
      if ((ref1 = this.lightbox.root) != null) {
        ref1.trigger('timeForCaption', $caption.get(0));
      }
    };

    return Swipe;

  })();


  /**
   *
   * @class MMG.Lightbox.LightboxSwipe
   *
   */

  MMG.Lightbox.LightboxSwipe = (function() {
    var Template;

    Template = MMG.View.Template;


    /**
     *
     * @constructor
     * @param {String} gridId
     * @param {Object} options
     *
     */

    function LightboxSwipe(gridId1, meta1) {
      this.gridId = gridId1;
      this.meta = meta1;
      this.close = bind(this.close, this);
      this._makeLightBox = bind(this._makeLightBox, this);
      this._show_ie9 = bind(this._show_ie9, this);
      this._show = bind(this._show, this);
      this._onResize = bind(this._onResize, this);
      this._hide = bind(this._hide, this);
      this._setVendorPrefix = bind(this._setVendorPrefix, this);
      this._removeStylesheet = bind(this._removeStylesheet, this);
      this._setStylesheet = bind(this._setStylesheet, this);
      this._replaceForRetina = bind(this._replaceForRetina, this);
      this._setAnimationName = bind(this._setAnimationName, this);
      this.show = bind(this.show, this);
      this.vendorPrefix = '-webkit-';
      this.isRetina = false;
      this.pixelRatio = 1;
      this.regexMatch = /\.[\w\?=]+$/;
      this.retinaSuffix = '@2x';
      this.count = 0;
      this.NS = 'mmg';
      this.options = this.meta.lightbox;
      this.isActive = false;
      this.current_index = 0;
      this._init();
    }


    /**
     *
     * @method _init
     * @private
     *
     */

    LightboxSwipe.prototype._init = function() {
      var grid, warning;
      warning = 'options parameter must be of an Object type!';
      if (this.options === void 0) {
        alert(warning);
      } else if (typeof this.options === 'string') {
        grid = this.options;
      } else if (typeof this.options === 'object') {
        grid = this.options.grid;
        if (this.options.retinaSuffix) {
          this.retinaSuffix = this.options.retinaSuffix;
        }
        this.pixelRatio = window.devicePixelRatio;
        if (this.options.retina) {
          this.isRetina = this.options.retina;
        }
        if (this.options.ns) {
          this.NS = options.ns + '-';
        }
        this.NSclass = '.' + this.NS + '-';
        if (this.options.name) {
          this.name = this.options.name;
        }
        this.captionHideAfter = this.options.captionHideAfter;
        if (this.options.swipe) {
          this.isSwipe = true;
          if (_.isObject(this.options.swipe)) {
            this.swipeOptions = this.options.swipe;
          } else {
            this.swipeOptions = {};
          }
          this.swipeName = this.swipeOptions.name || 'classica';
        }
      } else {
        alert(warning);
      }
      this.root = $(grid);
      this.ieVer = this._ieVer();
      this.loaderTemplate = $('<div id=\'' + this.NS + '-viewer-loader\'><span class=\'l1\'></span><span class=\'l2\'></span><span class=\'l3\'></span></div>');
      this._makeLightBox();
      this.bodyhtml = $('html, body');
      this.body = $('body');
      this.html = $('html');
      this.bodyOverflowX = this.body.css('overflow-x');
      this.bodyOverflowY = this.body.css('overflow-y');
      this.htmlOverflowX = this.html.css('overflow-x');
      this.htmlOverflowY = this.html.css('overflow-y');
      $(window).resize(this._onResize);
      this._setWin();
    };


    /**
     *
     * @method _setWin
     * @private
     *
     */

    LightboxSwipe.prototype._setWin = function() {
      var winHeight, winWidth;
      winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
      winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      this.container.css({
        width: winWidth,
        height: winHeight
      });
    };


    /**
     *
     * @method setData
     * @public
     *
     * Adds data to the swipe instance
     *
     */

    LightboxSwipe.prototype.setData = function(data) {
      this.data = data;
      if (this.isSwipe && this.swipe) {
        this.swipe.setData(data);
      }
    };


    /**
     *
     * @method show
     * @public
     * @param {Integer} index
     *
     */

    LightboxSwipe.prototype.show = function(index) {
      this._setWin();
      if (this.ieVer > 0 && this.ieVer < 10) {
        this._show_ie9(index);
      } else {
        this._show(index);
      }
    };


    /**
     *
     * @method _setAnimationName
     * @private
     *
     * specifies the animation name for the 'click' event
     *
     */

    LightboxSwipe.prototype._setAnimationName = function() {
      this.count++;
      return this.NS + '-lightbox-' + this.gridId + '-' + this.count;
    };


    /**
     *
     * @method _replaceForRetina
     * @private
     * @static
     * @param {String} src
     *
     * inserts Retina suffix if necessary
     *
     */

    LightboxSwipe.prototype._replaceForRetina = function(src) {
      var match, replaceSuffix;
      if (!this.isRetina || this.pixelRatio === 1) {
        return src;
      }
      if (src.indexOf(this.retinaSuffix) >= 0) {
        return src;
      }
      match = src.match(this.regexMatch);
      replaceSuffix = this.retinaSuffix + match[0];
      return src.replace(this.regexMatch, replaceSuffix);
    };


    /**
     *
     * @method _setStylesheet
     * @private
     * @param {String} styleString
     * @param {String} Class
     *
     */

    LightboxSwipe.prototype._setStylesheet = function(styleString, Class) {
      $('<style>', {
        "class": this.NS + '-' + Class,
        type: 'text/css'
      }).text(styleString).appendTo('head');
    };


    /**
     *
     * @method _removeStylesheet
     * @private
     * @param {String} Class
     *
     */

    LightboxSwipe.prototype._removeStylesheet = function(Class) {
      var style;
      style = this.NS + '-' + Class;
      $("head>style." + style).remove();
    };


    /**
     *
     * @method _setVendorPrefix
     * @private
     *
     */

    LightboxSwipe.prototype._setVendorPrefix = function() {
      if ('animation' in this.container.get(0).style) {
        this.vendorPrefix = '';
      }
    };


    /**
     *
     * @method _hide
     * @private
     * @param {Event} e
     * 
     * closes the Lightbox
     */

    LightboxSwipe.prototype._hide = function() {
      var ref, self;
      if (!this.isActive) {
        return;
      }
      this.isActive = false;
      self = this;
      if ((ref = this.loader) != null) {
        ref.remove();
      }
      this.bg.removeClass('mmg-on');
      setTimeout(function() {
        self.container.css({
          visibility: 'hidden',
          display: 'none'
        });
      }, 400);
      this.imageBlock.empty().removeAttr('style').removeClass(this.NS + '-animate');
      this.image = null;
      this.imageBlock.off();
      this._removeStylesheet('lightbox-animation');
      this.swipe._removeAll();
      this.body.css({
        'overflow-x': this.bodyOverflowX,
        'overflow-y': this.bodyOverflowY
      });
      this.html.css({
        'overflow-x': this.htmlOverflowX,
        'overflow-y': this.htmlOverflowY
      });
    };


    /**
     *
     * @method _onResize
     * @private
     *
     */

    LightboxSwipe.prototype._onResize = function() {
      var ref;
      this._setWin();
      if ((ref = this.swipe) != null) {
        ref.resize(this.isActive);
      }
    };


    /**
     *
     * @method _show
     * @private
     * opens the Lightbox with css animation
     */

    LightboxSwipe.prototype._show = function(index) {
      var bigHeight, bigLeft, bigTop, bigWidth, box, height, href, left, margins, onAnimationEnd, rect, self, top, width, winHeight, winWidth;
      this.isActive = true;
      self = this;
      this.bodyhtml.css({
        'overflow-x': 'hidden',
        'overflow-y': 'hidden'
      });
      onAnimationEnd = function(event) {
        self.swipe.setIndex(index);
        self.swipe.setup();
        $(self.swipe.getRoot()).one('loadend', function() {
          self.imageBlock.empty().removeAttr('style').css({
            visibility: 'hidden'
          }).removeClass(self.NS + '-animate');
          if (self.swipe.delay) {
            self.swipe.play();
          }
        });
        $(this).off('oanimationend MSAnimationEnd webkitAnimationEnd animationend');
      };
      this.container.css({
        display: 'block',
        visibility: 'visible'
      });
      setTimeout(function() {
        return self.bg.addClass('mmg-on');
      }, 50);
      winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
      winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      href = this.data[index].href;
      href = this._replaceForRetina(href);
      this.current_index = index;
      this.image = this.data[index].image;
      rect = this.swipe.getRect();
      margins = this.swipe.getMargins();
      box = this.image.get(0).getBoundingClientRect();
      top = box.top;
      left = box.left;
      width = box.right - left;
      height = box.bottom - top;
      bigWidth = rect.width * (1 - (margins.H / 50));
      bigHeight = rect.height * (1 - (margins.V / 50));
      bigTop = rect.top;
      bigLeft = rect.left;
      this.loader = this.loaderTemplate.clone().css({
        top: height / 2 - 8,
        left: width / 2 - 40
      });
      this.imageBlock.css({
        width: width,
        height: height,
        top: top,
        left: left
      }).append(this.loader);
      $('<img>').appendTo(this.imageBlock).one('load', function() {
        var finalX, finalY, initialX, initialY, name, newHeight, newWidth, ratio, scale, slideHeight, slideWidth, style, winRatio;
        self.loader.remove();
        $(this).addClass(self.NS + '-visible');
        slideWidth = this.naturalWidth;
        slideHeight = this.naturalHeight;
        ratio = slideWidth / slideHeight;
        winRatio = bigWidth / bigHeight;
        newHeight = slideHeight;
        newWidth = slideWidth;
        if (ratio > winRatio) {
          if (slideWidth > bigWidth) {
            newWidth = bigWidth;
            if (bigLeft == null) {
              bigLeft = rect.width * margins.H / 100;
            }
            newHeight = newWidth / ratio;
          }
        } else {
          if (slideHeight > bigHeight) {
            newHeight = bigHeight;
            if (bigTop == null) {
              bigTop = rect.height * margins.V / 100;
            }
            newWidth = newHeight * ratio;
          }
        }
        newHeight = Math.round(newHeight);
        newWidth = Math.round(newWidth);
        bigTop = Math.round(bigTop);
        bigLeft = Math.round(bigLeft);
        initialX = (width - newWidth) / 2;
        initialY = (height - newHeight) / 2;
        finalX = (width - newWidth) / 2 + (rect.width / 2) - (left + (width / 2)) + bigLeft;
        finalY = (height - newHeight) / 2 + (rect.height / 2) - (top + (height / 2)) + bigTop;
        scale = "scale3d(" + (width / newWidth) + ", " + (height / newHeight) + ", 1)";
        initialX = Math.round(initialX);
        initialY = Math.round(initialY);
        finalX = Math.round(finalX);
        finalY = Math.round(finalY);
        self.imageBlock.css({
          width: newWidth,
          height: newHeight,
          '-webkit-transform': ("translate3d(" + initialX + "px," + initialY + "px, 0) ") + scale,
          transform: ("translate3d(" + initialX + "px," + initialY + "px, 0) ") + scale
        });
        name = self._setAnimationName();
        style = '@' + self.vendorPrefix + 'keyframes ' + name + ' {' + '0% {' + self.vendorPrefix + 'transform: translate3d(' + initialX + 'px,' + initialY + 'px, 0) ' + scale + '}' + ' 40% {' + self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) ' + scale + ' }' + '100% {' + self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) scale3d(1,1,1)' + '}' + '}';
        self._setStylesheet(style, 'lightbox-animation');
        self.imageBlock.css(self.vendorPrefix + 'animation-name', name).addClass(self.NS + '-animate').one('oanimationend MSAnimationEnd webkitAnimationEnd animationend', onAnimationEnd);
        $(this).off('load');
      }).attr('src', href);
    };


    /**
     *
     * @method _show_ie9
     * @private
     * opens the Lightbox with jQuery animation
     * for ie8 and ie9
     *
     */

    LightboxSwipe.prototype._show_ie9 = function(index) {
      this.isActive = true;
      this.container.css({
        display: 'block',
        visibility: 'visible'
      });
      this.bg.stop(true).css({
        opacity: 0
      }).animate({
        opacity: 0.9
      }, 1000);
      this.swipe.setIndex(index);
      this.swipe.setup();
      $(this.swipe.getRoot()).one('loadend', (function(_this) {
        return function() {
          if (_this.swipe.delay) {
            _this.swipe.play();
          }
        };
      })(this));
    };


    /**
     *
     * @method _makeLightBox
     * @private
     * creates the markup
     *
     */

    LightboxSwipe.prototype._makeLightBox = function() {
      var devices, self, settings, swipeOptions;
      this.container = $('<div></div>', {
        "class": this.NS + '-lb',
        id: this.NS + '-lb-' + this.gridId.substr(6)
      }).css({
        display: 'none'
      }).appendTo('body');
      this.imageBlock = $('<div></div>', {
        "class": this.NS + '-center'
      }).appendTo(this.container);
      this.swipeContainer = $('<div></div>', {
        "class": this.NS + '-swipe-container'
      }).appendTo(this.container);
      this.bg = $('<div></div>', {
        "class": this.NS + '-lb-bg'
      }).appendTo(this.container);
      this.container.on('click touchend escape.mmg', (function(_this) {
        return function(e) {
          if (_this.isSwipe && e.type !== 'escape') {
            return;
          }
          _this.swipe.close();
        };
      })(this));
      self = this;
      $(document).on('keydown', function(e) {
        if (e.which === 27) {
          self.container.trigger('escape.mmg');
        }
      });
      this._setVendorPrefix();
      if (this.ieVer === 9) {
        this.container.addClass(this.NS + '-ie9');
      }
      if (this.ieVer === 8) {
        this.container.addClass(this.NS + '-ie8');
      }
      devices = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
      if (devices.test(navigator.userAgent)) {
        this.container.addClass(this.NS + '-lb-mb');
      }
      swipeOptions = {
        delayedSetup: true,
        resizable: false,
        close: this.close,
        captionName: this.name,
        lightbox: this.meta,
        captionHideAfter: this.captionHideAfter,
        useCaptionTemplate: _.partial(this.useCaptionTemplate, this.meta, this.gridId)
      };
      settings = _.extend(this.swipeOptions, swipeOptions);
      this.swipe = MMG.Lightbox.setSwipe(this.swipeName, this.swipeContainer.get(0), this.data, settings);
    };


    /**
     *
     * @method _ieVer
     * @private
     *
     */

    LightboxSwipe.prototype._ieVer = function() {
      var ver;
      ver = 0;
      switch (false) {
        case !(document.all && !document.querySelector):
          ver = 7;
          break;
        case !(document.all && !document.addEventListener):
          ver = 8;
          break;
        case !(document.all && !window.atob):
          ver = 9;
          break;
        case !document.all:
          ver = 10;
      }
      return ver;
    };


    /**
     *
     * @method close
     * @public
     *
     */

    LightboxSwipe.prototype.close = function() {
      var ref;
      if ((ref = this.swipe) != null) {
        ref.onClose();
      }
      this._hide();
    };

    LightboxSwipe.prototype.useCaptionTemplate = function(meta, gridId, data, name, index) {
      var compiled;
      if (!name) {
        return false;
      }
      compiled = MMG.View.Template.getTemplate(gridId, name, 'l').getCompiled();
      return compiled({
        meta: meta,
        data: data[index]
      });
    };

    return LightboxSwipe;

  })();


  /**
   *
   * @class class MMG.Lightbox.Lightbox
   *
   */

  MMG.Lightbox.Lightbox = (function() {
    var Template;

    Template = MMG.View.Template;


    /**
     *
     * @constructor
     * @param {String} gridId
     * @options {Object}
     *
     */

    function Lightbox(gridId1, meta1) {
      this.gridId = gridId1;
      this.meta = meta1;
      this.close = bind(this.close, this);
      this._makeLightBox = bind(this._makeLightBox, this);
      this._show_ie9 = bind(this._show_ie9, this);
      this._show = bind(this._show, this);
      this._onResize = bind(this._onResize, this);
      this._hide = bind(this._hide, this);
      this._setVendorPrefix = bind(this._setVendorPrefix, this);
      this._removeStylesheet = bind(this._removeStylesheet, this);
      this._setStylesheet = bind(this._setStylesheet, this);
      this._replaceForRetina = bind(this._replaceForRetina, this);
      this._setAnimationName = bind(this._setAnimationName, this);
      this.show = bind(this.show, this);
      this.vendorPrefix = '-webkit-';
      this.isRetina = false;
      this.isSimpleClick = true;
      this.pixelRatio = 1;
      this.regexMatch = /\.[\w\?=]+$/;
      this.retinaSuffix = '@2x';
      this.count = 0;
      this.NS = 'mmg';
      this.options = this.meta.lightbox;
      this.isActive = false;
      this.current_index = 0;
      this._init();
    }


    /**
     *
     * @method _init
     * @private
     *
     */

    Lightbox.prototype._init = function() {
      var grid, warning;
      warning = 'options parameter must be of an Object type!';
      if (this.options === void 0) {
        alert(warning);
      } else if (typeof this.options === 'string') {
        grid = this.options;
      } else if (typeof this.options === 'object') {
        grid = this.options.grid;
        if (this.options.retinaSuffix) {
          this.retinaSuffix = this.options.retinaSuffix;
        }
        this.pixelRatio = window.devicePixelRatio;
        if (this.options.retina) {
          this.isRetina = this.options.retina;
        }
        if (this.options.ns) {
          this.NS = options.ns + '-';
        }
        this.NSclass = '.' + this.NS + '-';
        if (this.options.simpleClick === false) {
          this.isSimpleClick = this.options.simpleClick;
        }
        if (this.options.captionHideAfter) {
          this.captionHideAfter = this.options.captionHideAfter;
        }
        if (this.options.name) {
          this.name = this.options.name;
        }
      } else {
        alert(warning);
      }
      this.root = $(grid);
      this.ieVer = this._ieVer();
      this.loaderTemplate = $('<div id=\'' + this.NS + '-viewer-loader\'><span class=\'l1\'></span><span class=\'l2\'></span><span class=\'l3\'></span></div>');
      this._makeLightBox();
      $(window).resize(this._onResize);
      this._onResize();
    };

    Lightbox.prototype.setData = function(data) {
      return this.data = data;
    };

    Lightbox.prototype.show = function(index) {
      this._onResize();
      if (this.ieVer > 0 && this.ieVer < 10) {
        return this._show_ie9(index);
      } else {
        return this._show(index);
      }
    };

    Lightbox.prototype._useCaptionTemplate = function() {
      var compiled;
      if (!this.name) {
        return false;
      }
      compiled = Template.getTemplate(this.gridId, this.name, 'l').getCompiled();
      return compiled({
        meta: this.meta,
        data: this.data[this.current_index]
      });
    };


    /**
     *
     * @method _setAnimationName
     * @private
     *
     * specifies the animation name for the 'click' event
     *
     */

    Lightbox.prototype._setAnimationName = function() {
      this.count++;
      return this.NS + '-lightbox-' + this.gridId + '-' + this.count;
    };


    /**
     *
     * @method _replaceForRetina
     * @private
     * @static
     * @param {String} src
     *
     * inserts Retina suffix if necessary
     *
     */

    Lightbox.prototype._replaceForRetina = function(src) {
      var match, replaceSuffix;
      if (!this.isRetina || this.pixelRatio === 1) {
        return src;
      }
      if (src.indexOf(this.retinaSuffix) >= 0) {
        return src;
      }
      match = src.match(this.regexMatch);
      replaceSuffix = this.retinaSuffix + match[0];
      return src.replace(this.regexMatch, replaceSuffix);
    };


    /**
     *
     * @method _setStylesheet
     * @private
     * @param {String} styleString
     * @param {String} Class
     *
     */

    Lightbox.prototype._setStylesheet = function(styleString, Class) {
      $('<style>', {
        "class": this.NS + '-' + Class,
        type: 'text/css'
      }).text(styleString).appendTo('head');
    };

    Lightbox.prototype._removeStylesheet = function(Class) {
      var style;
      style = this.NS + '-' + Class;
      $("head>style." + style).remove();
    };


    /**
     *
     * @method _setVendorPrefix
     * @private
     *
     */

    Lightbox.prototype._setVendorPrefix = function() {
      if ('animation' in this.container.get(0).style) {
        this.vendorPrefix = '';
      }
    };


    /**
     *
     * @method _hide
     * @private
     * @param {Event} e
     * 
     * closes the Lightbox
     */

    Lightbox.prototype._hide = function() {
      var ref, self;
      if (!this.isActive) {
        return;
      }
      this.isActive = false;
      self = this;
      this.loader.remove();
      this.bg.removeClass('mmg-on');
      setTimeout(function() {
        self.container.css({
          visibility: 'hidden',
          display: 'none'
        });
      }, 400);
      if ((ref = this.caption) != null) {
        ref.css('display', 'none');
      }
      this.imageBlock.empty().removeAttr('style').removeClass(this.NS + '-animate');
      this.caption = null;
      this.image = null;
      this.imageBlock.off();
      this._removeStylesheet('lightbox-animation');
      clearTimeout(this.captionHide);
    };


    /**
     *
     * @method _onResize
     * @private
     *
     */

    Lightbox.prototype._onResize = function() {
      var winHeight, winWidth;
      winHeight = window.innerHeight || screen.height;
      winWidth = window.innerWidth || screen.width;
      this.container.css({
        width: winWidth,
        height: winHeight
      });
    };


    /**
     *
     * @method _show
     * @private
     * opens the Lightbox with css animation
     */

    Lightbox.prototype._show = function(index) {
      var bigHeight, bigWidth, box, height, href, left, onAnimationEnd, self, string, top, width, winHeight, winWidth;
      this.isActive = true;
      self = this;
      onAnimationEnd = function(event) {
        var ref;
        if ((ref = self.caption) != null ? ref.get(0) : void 0) {
          self.caption.appendTo($(this)).css({
            display: 'block'
          });
          setTimeout((function() {
            self.caption.addClass(self.NS + '-lb-show');
            self.root.trigger('timeForCaption', self.caption.get(0));
          }), 50);
          if (self.captionHideAfter) {
            self.captionHide = setTimeout((function() {
              self.caption.removeClass(self.NS + '-lb-show');
              self.root.trigger('timeForCaptionHide', self.caption.get(0));
            }), self.captionHideAfter);
          }
        }
        $(this).off('oanimationend MSAnimationEnd webkitAnimationEnd animationend');
      };
      this.container.css({
        display: 'block',
        visibility: 'visible'
      });
      setTimeout(function() {
        return self.bg.addClass('mmg-on');
      }, 50);
      winHeight = window.innerHeight || screen.height;
      winWidth = window.innerWidth || screen.width;
      href = this.data[index].href;
      href = this._replaceForRetina(href);
      this.current_index = index;
      this.image = this.data[index].image;
      string = this._useCaptionTemplate();
      if (string) {
        this.caption = $(string);
      }
      box = this.image.get(0).getBoundingClientRect();
      top = box.top;
      left = box.left;
      width = box.right - left;
      height = box.bottom - top;
      bigWidth = winWidth * 0.9;
      bigHeight = winHeight * 0.9;
      this.loader = this.loaderTemplate.clone().css({
        top: height / 2 - 8,
        left: width / 2 - 40
      });
      this.imageBlock.css({
        width: width,
        height: height,
        top: top,
        left: left
      }).append(this.loader);
      $('<img>').appendTo(this.imageBlock).one('load', function() {
        var finalX, finalY, initialX, initialY, name, newHeight, newWidth, ratio, scale, slideHeight, slideWidth, style, winRatio;
        self.loader.remove();
        $(this).addClass(self.NS + '-visible');
        slideWidth = this.naturalWidth;
        slideHeight = this.naturalHeight;
        ratio = slideWidth / slideHeight;
        winRatio = winWidth / winHeight;
        newHeight = slideHeight;
        newWidth = slideWidth;
        if (ratio > winRatio) {
          if (slideWidth > bigWidth) {
            newWidth = bigWidth;
            newHeight = newWidth / ratio;
          }
        } else {
          if (slideHeight > bigHeight) {
            newHeight = bigHeight;
            newWidth = newHeight * ratio;
          }
        }
        newHeight = Math.round(newHeight);
        newWidth = Math.round(newWidth);
        initialX = (width - newWidth) / 2;
        initialY = (height - newHeight) / 2;
        finalX = (width - newWidth) / 2 + (winWidth / 2) - (left + (width / 2));
        finalY = (height - newHeight) / 2 + (winHeight / 2) - (top + (height / 2));
        scale = "scale3d(" + (width / newWidth) + ", " + (height / newHeight) + ", 1)";
        finalX = Math.round(finalX);
        finalY = Math.round(finalY);
        self.imageBlock.css({
          width: newWidth,
          height: newHeight,
          '-webkit-transform': ("translate3d(" + initialX + "px," + initialY + "px, 0) ") + scale,
          transform: ("translate3d(" + initialX + "px," + initialY + "px, 0) ") + scale
        });
        name = self._setAnimationName();
        style = '@' + self.vendorPrefix + 'keyframes ' + name + ' {' + '0% {' + self.vendorPrefix + 'transform: translate3d(' + initialX + 'px,' + initialY + 'px, 0) ' + scale + '}' + ' 40% {' + self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) ' + scale + ' }' + '100% {' + self.vendorPrefix + 'transform: translate3d(' + finalX + 'px,' + finalY + 'px, 0) scale3d(1,1,1)' + '}' + '}';
        self._setStylesheet(style, 'lightbox-animation');
        self.imageBlock.css(self.vendorPrefix + 'animation-name', name).addClass(self.NS + '-animate').one('oanimationend MSAnimationEnd webkitAnimationEnd animationend', onAnimationEnd);
        $(this).off('load');
      }).attr('src', href);
    };


    /**
     *
     * @method _show_ie9
     * @private
     * opens the Lightbox with jQuery animation
     * for ie8 and ie9
     *
     */

    Lightbox.prototype._show_ie9 = function(index) {
      var bigHeight, bigWidth, href, loaderTemplate, self, string, winHeight, winWidth;
      self = this;
      this.isActive = true;
      this.container.css({
        display: 'block',
        visibility: 'visible'
      });
      this.bg.stop(true).css({
        opacity: 0
      }).animate({
        opacity: 0.8
      }, 1000);
      winHeight = $(window).height();
      winWidth = $(window).width();
      href = this.data[index].href;
      href = this._replaceForRetina(href);
      this.current_index = index;
      this.image = this.data[index].image;
      string = this._useCaptionTemplate();
      if (string) {
        this.caption = $(string);
      }
      bigWidth = winWidth * 0.9;
      bigHeight = winHeight * 0.9;
      loaderTemplate = $('<div id=\'' + this.NS + '-viewer-loader\'></div>');
      this.loader = loaderTemplate.clone().css({
        top: winHeight / 2 - 50,
        left: winWidth / 2 - 50,
        opacity: 0
      }).appendTo(this.container).animate({
        opacity: 0.2
      });
      $('<img>').appendTo(this.imageBlock).one('load', function() {
        var newHeight, newWidth, ratio, ref, slideHeight, slideWidth, winRatio;
        self.loader.remove();
        $(this).addClass(self.NS + '-visible');
        slideWidth = $(this).naturalWidth();
        slideHeight = $(this).naturalHeight();
        ratio = slideWidth / slideHeight;
        winRatio = winWidth / winHeight;
        newHeight = slideHeight;
        newWidth = slideWidth;
        if (ratio > winRatio) {
          if (slideWidth > bigWidth) {
            newWidth = bigWidth;
            newHeight = newWidth / ratio;
          }
        } else {
          if (slideHeight > bigHeight) {
            newHeight = bigHeight;
            newWidth = newHeight * ratio;
          }
        }
        self.imageBlock.css({
          width: newWidth,
          height: newHeight,
          left: (winWidth - newWidth) / 2,
          top: (winHeight - newHeight) / 2
        }).stop(true).delay(200).animate({
          opacity: 1
        }, 400, 'swing', function() {
          if (!self.caption) {
            return;
          }
          self.root.trigger('timeForCaption', self.caption.get(0));
          if (self.captionHideAfter) {
            self.captionHide = setTimeout((function() {
              self.root.trigger('timeForCaptionHide', self.caption.get(0));
            }), self.captionHideAfter);
          }
        });
        if ((ref = self.caption) != null) {
          ref.appendTo(self.imageBlock).css({
            display: 'block'
          });
        }
        $(this).off('load');
      }).attr('src', href);
    };


    /**
     *
     * @method _makeLightBox
     * @private
     * creates the markup
     *
     */

    Lightbox.prototype._makeLightBox = function() {
      var devices, self;
      this.container = $('<div></div>', {
        "class": this.NS + '-lb',
        id: this.NS + '-lb-' + this.gridId.substr(6)
      }).css({
        display: 'none'
      }).appendTo('body');
      this.imageBlock = $('<div></div>', {
        "class": this.NS + '-center'
      }).appendTo(this.container);
      this.bg = $('<div></div>', {
        "class": this.NS + '-lb-bg'
      }).appendTo(this.container);
      this.container.on('click touchend escape.mmg', (function(_this) {
        return function(e) {
          if (!_this.isSimpleClick && $(e.target).parents("." + _this.NS + "-center").get(0) !== void 0) {
            return;
          }
          _this._hide();
        };
      })(this));
      self = this;
      $(document).on('keydown', function(e) {
        if (e.which === 27) {
          self.container.trigger('escape.mmg');
        }
      });
      this._setVendorPrefix();
      if (!this.isSimpleClick) {
        this.container.addClass(this.NS + '-noclick');
      }
      if (this.ieVer === 9) {
        this.container.addClass(this.NS + '-ie9');
      }
      if (this.ieVer === 8) {
        this.container.addClass(this.NS + '-ie8');
      }
      devices = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
      if (devices.test(navigator.userAgent)) {
        this.container.addClass(this.NS + '-lb-mb');
      }
    };


    /**
     *
     * @method _ieVer
     * @private
     *
     */

    Lightbox.prototype._ieVer = function() {
      var ver;
      ver = 0;
      switch (false) {
        case !(document.all && !document.querySelector):
          ver = 7;
          break;
        case !(document.all && !document.addEventListener):
          ver = 8;
          break;
        case !(document.all && !window.atob):
          ver = 9;
          break;
        case !document.all:
          ver = 10;
      }
      return ver;
    };

    Lightbox.prototype.close = function() {
      return this._hide();
    };

    return Lightbox;

  })();


  /**
   *
   * @class MMG.AJAX.Ajax
   *
   */

  MMG.AJAX.Ajax = (function() {

    /*
     * the Singleton Pattern is used
     */
    var Loader, Models, Parser, PrivatClass, instance;

    function Ajax() {}

    instance = {};

    Models = MMG.Data.Models;

    Loader = MMG.Utility.ImageLoader;

    Parser = MMG.Utility.Parser;


    /**
     * @method getParser
     * @param {String} gridId
     * @param {String} type
     * @public
     * a static method that is used to call the Parser instance
     */

    Ajax.getAjax = function(gridId, type) {
      if (type == null) {
        type = 'json';
      }
      return instance[gridId] != null ? instance[gridId] : instance[gridId] = new PrivatClass(gridId, type);
    };


    /**
     *
     * @class PrivateClass
     *
     */

    PrivatClass = (function() {

      /**
       * @constructor
       * @param {String} gridId
       * @param {String} type
       *
       */
      function PrivatClass(gridId1, type1) {
        this.gridId = gridId1;
        this.type = type1;
        this.getData = bind(this.getData, this);
        this.getDeferred = bind(this.getDeferred, this);
        this._loadHTML = bind(this._loadHTML, this);
        this._loadJSON = bind(this._loadJSON, this);
        this.load = bind(this.load, this);
        this._loadPics = bind(this._loadPics, this);
        this.data = [];
        this.model = Models[this.gridId];
        this.meta = this.model.meta;
        this.ok = $.Deferred();
      }

      PrivatClass.prototype._loadPics = function() {
        var loaded, self;
        self = this;

        /*
         * jQuery Deferred object
         */
        loaded = Loader.loadPics.call(this);

        /*
         * max timeout
         */

        /*
         * waits until all images are loaded
         * if an image is not loaded it is removed
         * frome the list
         */
        loaded.then(function() {
          Models[self.gridId].meta = self.meta;
          self.data = _.reject(self.data, function(el) {
            return el.height == null;
          });
          self.ok.resolve();
        });
      };


      /**
       *
       * @method load
       * @public
       * @param {String} url
       * @paran {Object} urlData
       */

      PrivatClass.prototype.load = function(url, urlData) {
        var root;
        if (urlData == null) {
          urlData = {};
        }
        if (url != null) {
          this.url = url;
        }
        root = this.meta.root;
        root.height(root.height());
        if (this.type === 'json') {
          this._loadJSON(url, urlData);
        } else {
          this._loadHTML(url, urlData);
        }
      };


      /**
       *
       * @method loadJSON
       * @public
       * @param {String} url
       * @paran {Object} urlData
       */

      PrivatClass.prototype._loadJSON = function(url, urlData) {
        var self;
        self = this;
        $.getJSON(url, urlData, function(inData) {
          var data;
          if (self.meta.jsonParser) {
            if (!_.isFunction(self.meta.jsonParser)) {
              console.error('jsonParser must be a function');
              self.data = {};
              return;
            } else {
              data = self.meta.jsonParser(inData);
            }
          } else {
            data = inData;
          }
          if (data[0].src) {
            self.data = data;
          } else {
            self.data = data[0];
            if (data[1]) {
              self.meta.lastLoadedMeta = data[1];
            }
          }
          self._loadPics();
        });
      };


      /**
       *
       * @method loadHTML
       * @public
       * @param {String} url
       * @paran {Object} urlData
       */

      PrivatClass.prototype._loadHTML = function(url, urlData) {
        var self;
        self = this;
        $.get(url, urlData, function(data) {
          var fragment, parser;
          fragment = $(document.createDocumentFragment());
          fragment.append(data);
          parser = Parser.getParser(self.gridId);
          self.data = parser.ajax(fragment);
          self._loadPics();
        }, 'html');
      };


      /**
       *
       * @methos getDeferred
       * @public
       * @return {jQuery.Deferred}
       *
       */

      PrivatClass.prototype.getDeferred = function() {
        return this.ok = $.Deferred();
      };


      /**
       *
       * @methos getData
       * @public
       * @return {Object}
       *
       */

      PrivatClass.prototype.getData = function() {
        return this.data;
      };

      return PrivatClass;

    })();

    return Ajax;

  })();


  /**
   *
   * @class MMG.Utility.NaturalSize
   * for old IE when native naturalWidth/naturalHeight
   * are undefined
   *
   * inspired by Jack Moore
   * http://www.jacklmoore.com/notes/naturalwidth-and-naturalheight-in-ie/
   *
   */

  MMG.Utility.NaturalSize = (function() {

    /*
     * the Singleton Pattern is used
     *
     */
    var PrivatClass, instance;

    function NaturalSize() {}

    instance = null;


    /**
     *
     * @method set
     * @public
     * @static
     *
     */

    NaturalSize.set = function() {
      return instance != null ? instance : instance = new PrivatClass();
    };


    /**
     *
     * @class PrivateClass
     *
     */

    PrivatClass = (function() {

      /**
       *
       * @constructor
       *
       */
      function PrivatClass() {
        this.setNaturalSize();
      }


      /**
       *
       * @method setNaturalSize
       * @public
       *
       */

      PrivatClass.prototype.setNaturalSize = function() {
        return (function($) {
          var prop, props, setProp;
          props = ['Width', 'Height'];
          prop = void 0;
          setProp = function(natural, prop) {
            $.fn[natural] = natural in new Image ? (function() {
              return this[0][natural];
            }) : (function() {
              var img, node, value;
              node = this[0];
              img = void 0;
              value = void 0;
              if (node.tagName.toLowerCase() === 'img') {
                img = new Image;
                img.src = node.src;
                value = img[prop];
              }
              return value;
            });
          };
          while (prop = props.pop()) {
            setProp('natural' + prop, prop.toLowerCase());
          }
        })(jQuery);
      };

      return PrivatClass;

    })();

    return NaturalSize;

  })();


  /**
   *
   * @class MMG.Data.ModelBuilder
   *
   */

  MMG.Data.ModelBuilder = (function() {
    var Data, Models, def;

    Models = MMG.Data.Models;

    def = MMG.Grid.def;

    Data = MMG.Data.Core;


    /**
     *
     * @constructor
     * @param {String} gridId
     * @param {Object} options
     *
     */

    function ModelBuilder(gridId1, options1) {
      this.gridId = gridId1;
      this.options = options1;
      this._setLBTemplate = bind(this._setLBTemplate, this);
      this._setTemplate = bind(this._setTemplate, this);
      this._setData = bind(this._setData, this);
      this._setMeta = bind(this._setMeta, this);
      this._registerModel = bind(this._registerModel, this);
      this._init = bind(this._init, this);

      /*
       * the array of items data:
       */
      this.data = [];

      /*
       * the object of metadata:
       */
      this.meta = {};
      this._init();
    }


    /**
     *
     * @method _init
     * @private
     *
     */

    ModelBuilder.prototype._init = function() {
      this._registerModel();
      this._setMeta();
      this._setTemplate();
      this._setLBTemplate();
      this._setData();
    };


    /**
     *
     * @method _registerModel
     * @private
     *
     */

    ModelBuilder.prototype._registerModel = function() {
      Models[this.gridId] = {
        data: [],
        meta: {},
        built: $.Deferred()
      };
    };


    /**
     *
     * @method _setMeta
     * @private
     *
     * sets metadata
     */

    ModelBuilder.prototype._setMeta = function() {
      var _o, devices, ieVer, mobileGridClass, warning;
      _o = this.options;
      warning = 'options parameter must be of a String or of an Object type!';

      /*
       * devicePixelRatio
       * calculated by the script
       */
      this.meta.pixelRatio = window.devicePixelRatio;
      devices = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Touch/i;
      if (devices.test(navigator.userAgent)) {

        /*
         *
         * is device is mobile
         * calculated by the script
         */
        this.meta.isMobile = true;
        if (this.meta.pixelRatio > 1.5) {
          this.meta.kVisible = 2;
          this.meta.scrollDelta = 2;
        } else {
          this.meta.kVisible = 1;
          this.meta.scrollDelta = 2;
        }
      }
      if (_o == null) {
        alert(warning);
      } else if (typeof _o === 'string') {
        this.meta.grid = _o;
        this.meta.root = $(this.meta.grid);
      } else if (typeof _o === 'object') {
        this.meta.grid = _o.grid;
        this.meta.root = $(this.meta.grid);
        if (_o.ns) {

          /*
           * Namespace
           * specified by the user
           * default: 'mmg-'
           */
          this.meta.NS = _o.ns + '-';
          this.meta.NSclass = '.' + this.meta.NS + '-';
          this.meta.NSevent = '.' + this.meta.NS;
        }
        if (_o.data) {

          /*
           * initial data,
           * specified by the user in the script itself
           */
          this.meta.data = _o.data;
        }
        if (_o.templateName) {

          /*
           * the name of the template
           * specified by the user
           * required
           */
          this.meta.templateName = _o.templateName;
        }
        if (_o.gridClass) {

          /*
           * the class that is added to the root element
           * specified by the user
           */
          this.meta.gridClass = _o.gridClass;
        }
        if (_o.mobileGridClass) {

          /*
           * the class that is added to the root element
           * specified by the user
           * for mobile devices
           */
          mobileGridClass = _o.mobileGridClass;
        }
        if (_o.vars) {

          /*
           * Pares of keys and values.
           * An object, that contains custom variables
           */
          this.meta.vars = _o.vars;
        }
        if (_o.url) {

          /*
           * An Url of JSON file that is used for data loading by AJAX.
           * specified by the user
           */
          this.meta.url = _o.url;
        }
        if (_o.parser) {

          /*
           * the function that is used as a parser
           * specified by the user
           */
          this.meta.parser = _o.parser;
        }
        if (_o.jsonParser) {

          /*
           * if defined it will be used to convert JSON object
           *
           * a function that is used as a parser
           * specified by the user
           */
          this.meta.jsonParser = _o.jsonParser;
        }
        if (_o.margin != null) {

          /*
           * margin-right and margin-bottom css properties
           * for items
           * specified by the user
           * default: 2
           * {Integer or '0'}
           */
          this.meta.margin = _o.margin - 0;
        }
        if (_o.retina != null) {

          /*
           * 0 - no Retina mode
           * 1,2 - Retina modes
           * specified by the user
           */
          this.meta.retina = _o.retina;
        }
        if (_o.retinaSuffix != null) {

          /*
           * Overrides the default retina suffix ('@2x')
           * specified by the user
           */
          this.meta.retinaSuffix = _o.retinaSuffix;
        }
        if (_o.height != null) {

          /*
           * the maximum height of a row
           * specified  by the user
           */
          this.meta.rowHeight = _o.height;
        }
        if (_o.timeout != null) {

          /*
           * the maximum loading time in ms
           * specified  by the user
           * default: 5000
           * {Integer}
           */
          this.meta.maxWait = _o.timeout;
        }
        if (_o.small != null) {

          /*
           * the maximum width for images witch can classified as 'small'
           * specified  by the user
           * default: 180
           * {Integer}
           */
          this.meta.maxSmall = _o.small;
        }
        if (_o.middle != null) {

          /*
           * the maximum width for images witch can classified as 'middle'
           * specified  by the user
           * default: 400
           * {Integer}
           */
          this.meta.maxMiddle = _o.middle;
        }
        if (_o.canvasFilters != null) {

          /*
           * the array of specified canvas filters
           * specified  by the user
           */
          this.meta.filters = _o.canvasFilters;
        }
        if (_o.twin != null) {

          /*
           * the 'twin' mode
           * default: false
           * {Boolean}
           */
          this.meta.twin = _o.twin;
        }
        if (_o.svgFiltersId != null) {

          /*
           * the ID of the appropriate SVG-filter
           * specified  by the user
           */
          this.meta.svgFiltersId = _o.svgFiltersId;

          /*
           * 
           * SVG-Filter usage
           * {Boolean}
           * default: false
           * calculated by the script
           */
          this.meta.SVGFilter = true;
        }
        if (_o.oldIEFilter != null) {

          /*
           * old-style MS-filter usage
           * for IE8, IE9
           * {Boolean}
           * default: false
           *  specified  by the user
           */
          this.meta.oldIEFilter = _o.oldIEFilter;
        }
        this.meta.excludeClass = 'mmg-external';
        if (_o.excludeClass != null) {
          this.meta.excludeClass = _o.excludeClass;
        }
        if (_o.excludable != null) {
          this.meta.excludable = _o.excludable;
        }
        if (_o.lightbox === false) {

          /*
           * 
           * the object of options for the built-in lightbox
           * or false
           * default: {}
           * specified by the user
           */
          this.meta.lightbox = false;
        } else if (typeof _o.lightbox === 'object') {
          this.meta.lightbox = _o.lightbox;
          this.meta.lightbox.grid = this.meta.grid;
        } else {
          this.meta.lightbox = {};
          this.meta.lightbox.grid = this.meta.grid;
        }
        if (_o.canvas !== void 0) {
          if (_o.canvas === 1) {

            /*
             * canvas usage
             * default: false
             * {Boolean}
             * calculated by the script
             */
            this.meta.useCanvas = true;
          } else if (_o.canvas === 2) {
            if (this.meta.isMobile) {
              this.meta.useCanvas = true;
            } else {
              this.meta.useCanvas = false;
            }
          } else {
            this.meta.useCanvas = false;
          }
        }
      } else {
        alert(warning);
      }
      ieVer = this._ieVer();

      /*
       * the version of IE
       * calculated by the script
       */
      this.meta.ieVer = ieVer;
      if (this.meta.isMobile && this.meta.useCanvas && this.meta.retina) {
        this.meta.kVisible = 1;
      }
      if (this.meta.isMobile && this.meta.filters && this.meta.retina) {
        this.meta.kVisible = 1;
      }
      if (this.meta.isMobile && this.meta.SVGFilter) {
        this.meta.kVisible = 1;
      }
      if (this.meta.isMobile && mobileGridClass) {
        this.meta.gridClass = mobileGridClass;
      }

      /*
       * SVG-filters support
       * {Boolean}
       * calculated by the script
       */
      this.meta.supportSVGFilters = (window['SVGFEColorMatrixElement'] != null) && SVGFEColorMatrixElement.SVG_FECOLORMATRIX_TYPE_SATURATE === 2;
      if (!this.meta.supportSVGFilters) {
        this.meta.SVGFilter = false;
      }
      this.meta.ieFilter = false;
      if (ieVer > 0 && ieVer < 10) {
        this.meta.SVGFilter = false;
        switch (this.meta.oldIEFilter) {
          case 'none':
            this.meta.useCanvas = false;
            this.meta.twin = false;
            break;
          case 'canvas':
            if (ieVer === 9) {
              this.meta.useCanvas = true;
            } else {
              this.meta.ieFilter = true;
              this.meta.useCanvas = false;
            }
            break;
          case 'css':
            this.meta.ieFilter = true;
            this.meta.useCanvas = false;
            break;
          default:
            this.meta.useCanvas = false;
            this.meta.twin = false;
        }
      } else {
        if (this.meta.SVGFilter) {
          this.meta.useCanvas = false;
        } else if (this.meta.filters) {
          this.meta.useCanvas = true;
        } else {
          this.meta.twin = false;
          if (_o.forcedTwin) {
            this.meta.forcedTwin = true;
          }
        }
      }

      /*
       * the window width and height
       * {Integer}
       * calculated by the script
       */
      this.meta.winWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
      this.meta.winHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;

      /*
       * the minumum height of images
       * calculated by the script
       * {Integer}
       * default: Infinity
       */
      this.meta.minHeight = Infinity;
      _.defaults(this.meta, def);
      Models[this.gridId].meta = this.meta;
      this.meta.loader = {
        loading: 0,
        loaded: 0,
        end: false,
        rate: 0,
        refresh: function() {
          this.loading = 0;
          this.loaded = 0;
          this.end = false;
          this.rate = 0;
        },
        observer: function(f1, f2) {
          var observe, prev;
          prev = 0;
          this.refresh();
          observe = (function(_this) {
            return function() {
              if (_this.loaded !== prev || _this.loaded === 0) {
                f1.call(_this);
                prev = _this.loaded;
              }
              if (!_this.end) {
                setTimeout(observe, 50);
              } else {
                f2.call(_this);
              }
            };
          })(this);
          observe();
        }
      };
    };


    /**
     *
     * @method _setData
     * @private
     * @param {String} gridId
     *
     */

    ModelBuilder.prototype._setData = function() {
      new Data(this.gridId);
    };


    /**
     *
     * @method _setTemplate
     * @private
     * sets meta.template and meta.callback
     *
     */

    ModelBuilder.prototype._setTemplate = function() {
      if (this.options.templateName) {
        this.meta.templateName = this.options.templateName;
      } else {
        this.meta.templateName = 'Simple';
      }
    };


    /**
     *
     * @method _setLBTemplate
     * @private
     *
     */

    ModelBuilder.prototype._setLBTemplate = function() {
      MMG.Lightboxes["default"] = {};
      MMG.Lightboxes["default"].template = "<% var title %>\n<% if (data.lb && data.lb.title) { title = data.lb.title %>\n<% } else if (data.face && data.face.title) { title = data.face.title %>\n<% } else { title = data.title } %>\n<div class='<%=meta.NS %>-lb-caption <%=meta.NS %>-lb-default'>\n  <div class='<%=meta.NS %>-lb-title'>\n  <%= title %>\n  </div>\n  <div class='<%=meta.NS %>-lb-bg-caption'></div>\n</div>";
      MMG.Lightboxes["default"].ie9 = {};
      MMG.Lightboxes["default"].ie9.callback = function() {
        var meta, self;
        self = this;
        meta = this.model.meta;
        meta.root.on('timeForCaption', function(event, caption) {
          $(meta.NSclass + 'lb-title', caption).stop(true).delay(200).animate({
            opacity: 1
          });
          return $(meta.NSclass + 'lb-bg-caption', caption).stop(true).animate({
            opacity: 1,
            bottom: 0
          });
        });
        meta.root.on('timeForCaptionHide', function(event, caption) {
          $(meta.NSclass + 'lb-title', caption).stop(true).animate({
            opacity: 0
          });
          $(meta.NSclass + 'lb-bg-caption', caption).stop(true).delay(200).animate({
            opacity: 0,
            bottom: '-100%'
          });
        });
      };
    };


    /**
     *
     * @method _ieVer
     * @private
     *
     */

    ModelBuilder.prototype._ieVer = function() {
      var ver;
      ver = 0;
      switch (false) {
        case !(document.all && !document.querySelector):
          ver = 7;
          break;
        case !(document.all && !document.addEventListener):
          ver = 8;
          break;
        case !(document.all && !window.atob):
          ver = 9;
          break;
        case !document.all:
          ver = 10;
      }
      return ver;
    };

    return ModelBuilder;

  })();


  /**
   *
   * @class MMG.Lightbox.External
   *
   * Contains 3 static methods which are used by MMG.Grid.Grid class
   * for initializing external lightboxes
   *
   */

  MMG.Lightbox.External = (function() {
    function External() {}


    /**
     *
     * @method colorBox
     * @public
     * @static
     * @param {Object} options - an object of native colorBox options
     * @param {Object} cbs - an object of callbacks: 
     *   getTitle - returns the caption title
     *     default: ''
     *   getHref - returns the src of the image to be shown
     *     default: item.href
     *  @return {colorBox}
     *
     */

    External.colorBox = function(options, cbs) {
      var anchorContainer, cb, gallery, meta, model, ns, root, rootSelector;
      if (options == null) {
        options = {};
      }
      if (cbs == null) {
        cbs = {};
      }
      if (cbs.getTitle == null) {
        cbs.getTitle = function(item) {
          return '';
        };
      }
      if (cbs.getHref == null) {
        cbs.getHref = function(item) {
          return item.href;
        };
      }
      model = this.model;
      meta = model.meta;
      root = meta.root;
      rootSelector = meta.grid;
      ns = meta.NS;
      gallery = $();
      anchorContainer = $('<div>', {
        id: 'anchor-container',
        style: 'display: none'
      }).appendTo('body');
      cb = null;
      root.on('dataLoaded', function(e, data) {
        var datas, settings;
        if (cb) {
          cb.remove();
        }
        anchorContainer.empty();
        gallery = $();
        datas = data.all;
        datas.forEach(function(item) {
          var anchor;
          anchor = '<a href="' + cbs.getHref(item) + '" rel="gal" title="' + cbs.getTitle(item) + '"></a>';
          gallery = gallery.add(anchor);
        });
        anchorContainer.append(gallery);
        settings = $.extend({}, {
          rel: 'gal'
        }, options);
        cb = gallery.colorbox(settings);
      });
      return $('body').on('click', "." + ns + "-link", function(e) {
        var id;
        e.preventDefault();
        id = $(this).parents("." + ns + "-img").attr('data-image-id');
        gallery.eq(id).click();
      });
    };


    /**
     *
     * @method photoSwipe
     * @public
     * @static
     * @param {Object} options - an object of native photoSwipe options
     * @param {Object} cbs - an object of callbacks: 
     *   getTitle - returns the caption title
     *
     *   getHref - returns the src of the image to be shown
     *     default: item.href
     *   getMsrc - returns the src of the appropriate icon
     *     default: item.src
     *   getWidth: returns the width of the image. Required
     *   getHeight: returns the height of the image. Required
     *
     *   callbacks for reseved params
     *   which anyone can use in his caption templates:
     *   getD1 - returns the value of d1
     *   getD2 - returns the value of d2
     *   getD3 - returns the value of d3
     *   getD4 - returns the value of d4
     *
     *  @return {photoSwipe}
     *
     */

    External.photoSwipe = function(options, cbs) {
      var defaults, gallery, getItems, index, items, meta, model, ns, pswpElement, root, rootSelector;
      if (options == null) {
        options = {};
      }
      if (cbs == null) {
        cbs = {};
      }
      if (!(cbs.getHight || cbs.getWidth)) {
        console.error('getWidth and getHeight must be specified!');
      }
      if (cbs.getMsrc == null) {
        cbs.getMsrc = function(item) {
          return item.src;
        };
      }
      if (cbs.getHref == null) {
        cbs.getHref = function(item) {
          return item.href;
        };
      }
      model = this.model;
      meta = model.meta;
      root = meta.root;
      rootSelector = meta.grid;
      ns = meta.NS;
      getItems = function(data) {
        var result;
        result = [];
        _.each(data, function(item) {
          var slide;
          slide = void 0;
          slide = {};
          slide.src = cbs.getHref(item);
          slide.msrc = cbs.getMsrc(item);
          slide.title = typeof cbs.getTitle === "function" ? cbs.getTitle(item) : void 0;
          slide.w = cbs.getWidth(item);
          slide.h = cbs.getHeight(item);
          slide.d1 = typeof cbs.getD1 === "function" ? cbs.getD1(item) : void 0;
          slide.d2 = typeof cbs.getD2 === "function" ? cbs.getD2(item) : void 0;
          slide.d3 = typeof cbs.getD3 === "function" ? cbs.getD3(item) : void 0;
          slide.d4 = typeof cbs.getD4 === "function" ? cbs.getD4(item) : void 0;
          result.push(slide);
        });
        return result;
      };
      pswpElement = $('.pswp')[0];
      if (!pswpElement) {
        pswpElement = $("<div tabindex='-1' role='dialog' aria-hidden='true' class='pswp'> <div class='pswp__bg'></div> <div class='pswp__scroll-wrap'> <div class='pswp__container'> <div class='pswp__item'></div> <div class='pswp__item'></div> <div class='pswp__item'></div> </div> <div class='pswp__ui pswp__ui--hidden'> <div class='pswp__top-bar'> <div class='pswp__counter'></div> <button title='Close (Esc)' class='pswp__button pswp__button--close'></button> <button title='Share' class='pswp__button pswp__button--share'></button> <button title='Toggle fullscreen' class='pswp__button pswp__button--fs'></button> <button title='Zoom in/out' class='pswp__button pswp__button--zoom'></button> <div class='pswp__preloader'> <div class='pswp__preloader__icn'> <div class='pswp__preloader__cut'> <div class='pswp__preloader__donut'></div> </div> </div> </div> </div> <div class='pswp__share-modal pswp__share-modal--hidden pswp__single-tap'> <div class='pswp__share-tooltip'></div> </div> <button title='Previous (arrow left)' class='pswp__button pswp__button--arrow--left'></button> <button title='Next (arrow right)' class='pswp__button pswp__button--arrow--right'></button> <div class='pswp__caption'> <div class='pswp__caption__center'></div> </div> </div> </div> </div>").appendTo('body').get(0);
      }
      items = [];
      index = 0;
      gallery = null;
      defaults = {
        index: 0
      };
      $('#container').on('dataLoaded', function(e, data) {
        var length;
        length = void 0;
        length = data.all.length;
        items = getItems(data.all);
        index = length;
      });
      return $('#container').on('click', "." + ns + "-link", function(e) {
        var image, settings;
        e.preventDefault();
        image = $(this).parents("." + ns + "-img");
        index = image.attr('data-image-id') * 1;
        defaults = {
          index: index,
          showAnimationDuration: 500,
          hideAnimationDuration: 500,
          showHideOpacity: true,
          getThumbBoundsFn: function(index) {
            var pageYScroll, rect, thumbnail;
            thumbnail = image.find("." + ns + "-icon").get(0);
            pageYScroll = window.pageYOffset || document.documentElement.scrollTop;
            rect = thumbnail.getBoundingClientRect();
            return {
              x: rect.left,
              y: rect.top + pageYScroll,
              w: rect.width
            };
          }
        };
        settings = $.extend({}, defaults, options);
        gallery = null;
        gallery = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, items, settings);
        gallery.init();
      });
    };

    return External;

  })();


  /**
   *
   * @class MMG.Grid.Grid
   *
   * The main class of this script
   *
   * @example
   * 
   * var grid = new MMG.Grid.Grid(options);
   *
   */

  MMG.Grid.Grid = (function() {
    var Ajax, Builder, Lightbox, LightboxSwipe, Models, Size, Template, View;

    Builder = MMG.Data.ModelBuilder;

    Models = MMG.Data.Models;

    Size = MMG.Utility.NaturalSize;

    View = MMG.View.View;

    Ajax = MMG.AJAX.Ajax;

    Lightbox = MMG.Lightbox.Lightbox;

    LightboxSwipe = MMG.Lightbox.LightboxSwipe;

    Template = MMG.View.Template;


    /**
     *
     * @constructor
     * @param {Object} options
     *
     */

    function Grid(options1) {
      this.options = options1;
      this.getLastLoadedMeta = bind(this.getLastLoadedMeta, this);
      this.getExternalLightbox = bind(this.getExternalLightbox, this);
      this._makeGrid = bind(this._makeGrid, this);
      this._setLightbox = bind(this._setLightbox, this);
      this._resetView = bind(this._resetView, this);
      this.loadByAjax = bind(this.loadByAjax, this);
      this._setModel = bind(this._setModel, this);
      this._init = bind(this._init, this);
      this.gridId = _.uniqueId('model_');
      this.model = {};
      this.ajax = null;
      this.view = null;
      this._init();
    }


    /**
     *
     * @method _init
     * @private
     */

    Grid.prototype._init = function() {
      this._setArrayIndexOf();
      Size.set();
      this._setModel();
      this._setLightbox();
    };


    /**
     *
     * @method _setModel
     * @private
     */

    Grid.prototype._setModel = function() {
      var self;
      new Builder(this.gridId, this.options);
      this.model = Models[this.gridId];
      self = this;
      this.model.built.then(function() {
        self._makeGrid();
      });
    };


    /**
     *
     * @method _makeView
     * @private
     */

    Grid.prototype._makeView = function() {
      this.view = new View(this.gridId);
    };


    /**
     *
     * @methos loadByAjax
     * @public
     * @param {String} url 
     * @param {Object} urlData The object of data or {}
     * @param {String} type 'json'(default) or 'html'
     *
     * @example
     *
     *  grid.loadByAjax('json/load2.json');
     *
     */

    Grid.prototype.loadByAjax = function(url, urlData, type) {
      var loaded;
      this.ajax = Ajax.getAjax(this.gridId, type);
      loaded = this.ajax.getDeferred();
      this.ajax.load(url, urlData);
      loaded.then(this._resetView);
    };


    /**
     *
     * @method _resetView
     * @private
     *
     */

    Grid.prototype._resetView = function() {
      var data;
      data = this.ajax.getData();
      this.view.add(data);
    };


    /**
     *
     * @method _setLightbox
     * @private
     * creates the Lightbox
     */

    Grid.prototype._setLightbox = function() {
      if (this.model.meta.lightbox) {
        if (this.model.meta.lightbox.swipe) {
          this.lb = new LightboxSwipe(this.gridId, this.model.meta);
        } else {
          this.lb = new Lightbox(this.gridId, this.model.meta);
        }
        this.lb.open = _.wrap(this.lb.show, (function(_this) {
          return function(func, index) {
            var data, index1;
            if (_this.model.meta.excludable) {
              data = _.reject(_this.model.data, function(item) {
                return item.excluded;
              });
              index1 = _.map(data, function(item) {
                var ref;
                return (ref = item.image) != null ? ref.attr('data-image-id') : void 0;
              }).indexOf(index);
            } else {
              data = _this.model.data;
              index1 = index;
            }
            _this.lb.setData(data);
            return func(index1);
          };
        })(this));
        this.model.meta.root.on('click', this.model.meta.NSclass + 'link', (function(_this) {
          return function(event) {
            var image, index;
            if ($(event.target).hasClass(_this.model.meta.NS + "-img")) {
              image = $(event.target);
            } else {
              image = $(event.target).parents("." + _this.model.meta.NS + "-img");
            }
            if (_this.model.meta.excludable && image.hasClass(_this.model.meta.excludeClass)) {
              return;
            }
            event.preventDefault();
            index = image.attr('data-image-id');
            _this.lb.open(index);
          };
        })(this));
      }
    };


    /**
     *
     * @method _makeGrid
     * @private
     *
     */

    Grid.prototype._makeGrid = function() {
      var klass, meta, root, wrapper;
      meta = this.model.meta;
      root = meta.root;
      root.wrap("<div class='" + meta.NS + "-grid-wrapper'></div>");
      root.width(root.width()).addClass(meta.NS + '-grid');
      wrapper = root.parent();
      wrapper.css({
        width: '100%',
        overflow: 'hidden'
      });
      klass = meta.gridClass;
      if (klass) {
        root.addClass(klass);
      }
      if (meta.twin) {
        root.addClass(meta.NS + '-twin');
      }
      if (meta.isMobile) {
        root.addClass(meta.NS + '-mb');
      }
      if (meta.ieVer === 9) {
        root.addClass(meta.NS + '-ie9');
      }
      if (meta.ieVer === 8) {
        root.addClass(meta.NS + '-ie8');
      }
      this._makeView();
    };


    /**
     *
     * Factory function for creating colorBox or photoSwipe or prettyPhoto
     *
     * @method getExternalLightbox
     * @public
     * @param {String} lb - may be: 'colorbox', 'photoswipe', 'prettyphoto'
     * @param {Object} options - native lightbox options
     * @param {Object} cbs - callback functions
     * @return lightbox object
     *
     */

    Grid.prototype.getExternalLightbox = function(lb, options, cbs) {
      switch (lb) {
        case 'colorbox':
          return MMG.Lightbox.External.colorBox.call(this, options, cbs);
        case 'prettyphoto':
          return console.log('PrettyPhoto is not supported any more!!!');
        case 'photoswipe':
          return MMG.Lightbox.External.photoSwipe.call(this, options, cbs);
        default:
          return console.error('Wrong lightbox parameter!');
      }
    };

    Grid.prototype.getLastLoadedMeta = function() {
      var ref;
      return (ref = this.model.meta) != null ? ref.lastLoadedMeta : void 0;
    };

    Grid.prototype.getLightbox = function() {
      return this.lb;
    };

    Grid.prototype.getLoader = function() {
      return this.model.meta.loader;
    };


    /**
     *
     * if Array.prototype.indexOf method doesn't exist (ie8)
     * this methord will solve the problem
     *
     */

    Grid.prototype._setArrayIndexOf = function() {
      if (!Array.prototype.indexOf) {
        return Array.prototype.indexOf = function(searchElement, fromIndex) {
          var O, k, len, n;
          k = void 0;
          if (this === null) {
            throw new TypeError('"this" is null or not defined');
          }
          O = Object(this);
          len = O.length >>> 0;
          if (len === 0) {
            return -1;
          }
          n = +fromIndex || 0;
          if (Math.abs(n) === Infinity) {
            n = 0;
          }
          if (n >= len) {
            return -1;
          }
          k = Math.max((n >= 0 ? n : len - Math.abs(n)), 0);
          while (k < len) {
            if (k in O && O[k] === searchElement) {
              return k;
            }
            k++;
          }
          return -1;
        };
      }
    };

    return Grid;

  })();


  /**
   *
   * the factory fanction
   *
   * @param {String} name - a name of the template
   * @param {Object} options
   * @param {Boolean} grayscale - if true, the script will create the SVG grayscale
   * filter element and append it to the body. Default true.
   * @return {MMG.Grid.Grid}
   * this factory function is used to create MMG.Grid.Grid class
   * it's useful when the template gives us the object of default options
   *
   * In general it's better to use this function instead of a constructor
   *
   */

  MMG.Gallery = function(name, options, grayscale) {
    var defaults, filterElement, settings;
    if (grayscale == null) {
      grayscale = true;
    }
    defaults = MMG.Templates[name].defaults;
    if (defaults == null) {
      defaults = {};
    }
    if (options == null) {
      options = {};
    }
    settings = $.extend({}, defaults, options);
    if (settings.svgFiltersId === 'grayscale' && grayscale) {
      filterElement = '<svg width="0" height="0"><defs><filter id="grayscale"><fecolormatrix type="saturate" values="0"></fecolormatrix></filter></defs></svg>';
      $(filterElement).appendTo('body');
    }
    return new MMG.Grid.Grid(settings);
  };

  MMG = window.MMG;

  MMG.Templates.Simple = {};

  MMG.Templates.Simple.template = "<div class='<%=meta.NS %>-img <%= data.classList %>' data-image-id='<%= imageId %>'> <% if(data.href) { %> <a href='<%= data.href %>' class='<%=meta.NS %>-link' rel='gal'> <% } %> <% if(data.face) { %> <div class='<%=meta.NS %>-f-caption'> <% if(data.face&&data.face.descr) { %> <div class='<%=meta.NS %>-descr'> <span class='<%=meta.NS %>-caption-bg'> <%= data.face.descr %> </span> </div> <% } %> <% if(data.face&&data.face.title) { %> <h3 class='<%=meta.NS %>-title'> <span class='<%=meta.NS %>-title-bg'> <%= data.face.title %> </span> </h3> <% } %> <% if(data.face&&data.face.secondDescr) { %> <div class='<%=meta.NS %>-footer'> <span class='<%=meta.NS %>-caption-bg'> <%= data.face.secondDescr %> </span> </div> <% } %> </div> <% } %> <img class='<%=meta.NS %>-icon <%=meta.NS %>-fs' src='<%= data.src %>'> <% if(data.href) { %> </a> <% } %> </div>";

  MMG.Templates.Simple.defaults = {
    templateName: 'Simple'
  };

}).call(this);
