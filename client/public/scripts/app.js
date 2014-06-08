(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';

    if (has(cache, path)) return cache[path].exports;
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex].exports;
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  var list = function() {
    var result = [];
    for (var item in modules) {
      if (has(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.list = list;
  globals.require.brunch = true;
})();
require.register("application", function(exports, require, module) {
module.exports = {
  initialize: function() {
    var Router;
    Router = require("router");
    this.router = new Router();
    Backbone.history.start();
  }
};
});

;require.register("collections/bookmarks", function(exports, require, module) {
var Bookmark, Bookmarks;

Bookmark = require("../models/bookmark");

module.exports = Bookmarks = Backbone.Collection.extend({
  model: Bookmark,
  url: "bookmarks"
});
});

;require.register("initialize", function(exports, require, module) {
$(document).ready(function() {
  var app;
  Swag.Config.partialsPath = './views/templates/';
  app = require("application");
  app.initialize();
});
});

;require.register("libs/communityMapping", function(exports, require, module) {
module.exports = function(fileText, separator) {
  var communities, line, lines, _i, _len;
  if (separator == null) {
    separator = " ";
  }
  communities = [];
  lines = fileText.split(/\r\n|\r|\n/g);
  for (_i = 0, _len = lines.length; _i < _len; _i++) {
    line = lines[_i];
    if (line.length) {
      communities.push(line.split(separator));
    }
  }
  return communities;
};
});

;require.register("libs/dataMapping", function(exports, require, module) {
module.exports = function(fileText, separator, header) {
  var communities, key, line, lines, localLine, _i, _len;
  if (separator == null) {
    separator = " ";
  }
  if (header == null) {
    header = false;
  }
  communities = {};
  lines = fileText.split(/\r\n|\r|\n/g);
  if (header) {
    header = lines[0];
    header = header.split(separator);
    lines.splice(0, 1);
  }
  for (_i = 0, _len = lines.length; _i < _len; _i++) {
    line = lines[_i];
    if (line.length) {
      localLine = line.split(separator);
      key = "" + localLine[0] + localLine[1];
      communities[key] = localLine;
    }
  }
  communities["header"] = header;
  return communities;
};
});

;require.register("models/bookmark", function(exports, require, module) {
var Bookmark;

module.exports = Bookmark = Backbone.Model.extend({});
});

;require.register("router", function(exports, require, module) {
var AppHome, Router;

AppHome = require("views/communityHome");

module.exports = Router = Backbone.Router.extend({
  routes: {
    "": "main"
  },
  main: function() {
    var mainView;
    mainView = new AppHome({});
    mainView.render();
  }
});
});

;require.register("templates/bookmark", function(exports, require, module) {
module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, foundHelper, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;


  buffer += "<a href=\"";
  foundHelper = helpers.bookmark;
  stack1 = foundHelper || depth0.bookmark;
  stack1 = (stack1 === null || stack1 === undefined || stack1 === false ? stack1 : stack1.url);
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "bookmark.url", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\" target=\"_blank\">";
  foundHelper = helpers.bookmark;
  stack1 = foundHelper || depth0.bookmark;
  stack1 = (stack1 === null || stack1 === undefined || stack1 === false ? stack1 : stack1.title);
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "bookmark.title", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</a>\r\n\r\n&nbsp; (\r\n<a class=\"delete\">delete</a>\r\n)\r\n";
  return buffer;});
});

require.register("templates/communityHome", function(exports, require, module) {
module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<h1>Community Detection Algorithms Visualization App</h1>\r\n\r\n<div class=\"box\">\r\n    <label>Please Choose the data file:</label>\r\n    <br />\r\n    <input type=\"file\" name=\"files\" id=\"initial\" />\r\n</div>\r\n\r\n<div class=\"box\">\r\n    <label>Please Choose the communities file:</label>\r\n    <br />\r\n    <input type=\"file\" name=\"files\" id=\"final\" />\r\n</div>\r\n\r\n<h2>Results</h2>\r\n<div id=\"resultsTemplate\"></div>";});
});

require.register("templates/home", function(exports, require, module) {
module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<h1>Welcome on My Own Bookmarks</h1>\r\n<p>This application will help you manage your bookmarks!</p>\r\n<form>\r\n    <label>Title:</label>\r\n    <input type=\"text\" name=\"title\"/>\r\n    <label>Url:</label>\r\n    <input type=\"text\" name=\"url\"/>\r\n    <input id=\"add-bookmark\" type=\"submit\" value=\"Add a new bookmark\"/>\r\n</form>\r\n<ul></ul>";});
});

require.register("templates/results", function(exports, require, module) {
module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, stack2, foundHelper, tmp1, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "<p class=\"error\">";
  foundHelper = helpers.error;
  stack1 = foundHelper || depth0.error;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "error", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</p>";
  return buffer;}

  foundHelper = helpers.error;
  stack1 = foundHelper || depth0.error;
  stack2 = helpers['if'];
  tmp1 = self.program(1, program1, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\r\n";
  return buffer;});
});

require.register("views/app_view", function(exports, require, module) {
var AppView, BookmarkView;

BookmarkView = require("./bookmark");

module.exports = AppView = Backbone.View.extend({
  el: "body",
  template: require("../templates/home"),
  events: {
    "click #add-bookmark": "createBookmark"
  },
  initialize: function() {
    this.listenTo(this.collection, "add", this.onBookmarkAdded);
  },
  render: function() {
    this.$el.html(this.template());
    this.collection.fetch();
  },
  createBookmark: function(event) {
    event.preventDefault();
    this.collection.create({
      title: this.$el.find("input[name=\"title\"]").val(),
      url: this.$el.find("input[name=\"url\"]").val()
    });
  },
  onBookmarkAdded: function(bookmark) {
    var bookmarkView;
    bookmarkView = new BookmarkView({
      model: bookmark
    });
    bookmarkView.render();
    this.$el.find("ul").append(bookmarkView.$el);
  }
});
});

;require.register("views/bookmark", function(exports, require, module) {
var Bookmark;

module.exports = Bookmark = Backbone.View.extend({
  tagName: "li",
  template: require("../templates/bookmark"),
  events: {
    "click a.delete": "deleteBookmark"
  },
  render: function() {
    this.$el.html(this.template({
      bookmark: this.model.toJSON()
    }));
  },
  deleteBookmark: function() {
    this.model.destroy();
    this.remove();
  }
});
});

;require.register("views/communityHome", function(exports, require, module) {
var BaseView, ResultsView, View, communityMapping, dataMapping,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require("./view");

dataMapping = require("../libs/dataMapping");

communityMapping = require("../libs/communityMapping");

ResultsView = require("./results");

module.exports = View = (function(_super) {
  __extends(View, _super);

  function View() {
    this.loadFile = __bind(this.loadFile, this);
    this.processFinal = __bind(this.processFinal, this);
    this.processInitial = __bind(this.processInitial, this);
    this.afterRender = __bind(this.afterRender, this);
    this.init = __bind(this.init, this);
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.el = "body";

  View.prototype.template = require("../templates/communityHome");

  View.prototype.events = {
    "change #initial": "loadFile",
    "change #final": "loadFile"
  };

  View.prototype.init = function() {
    this.initialData = {};
    return this.finalData = [];
  };

  View.prototype.afterRender = function() {
    var resultsView;
    resultsView = new ResultsView({
      initialData: this.initialData,
      finalData: this.finalData
    });
    return this.$el.find("#resultsTemplate").append(resultsView.render().$el);
  };

  View.prototype.processInitial = function() {
    this.initialData = dataMapping(event.target.result, ",", true);
    return this.render();
  };

  View.prototype.processFinal = function() {
    this.finalData = communityMapping(event.target.result);
    return this.render();
  };

  View.prototype.loadFile = function(e) {
    var fileRef, inputId, reader;
    inputId = $(e.target).attr("id");
    fileRef = e.target.files[0];
    reader = new FileReader();
    reader.onload = ((function(_this) {
      return function(theFile) {
        return function(event) {
          if (inputId === "initial") {
            return _this.processInitial();
          } else {
            return _this.processFinal();
          }
        };
      };
    })(this))(fileRef);
    return reader.readAsText(fileRef);
  };

  return View;

})(BaseView);
});

;require.register("views/results", function(exports, require, module) {
var BaseView, View,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require("./view");

module.exports = View = (function(_super) {
  __extends(View, _super);

  function View() {
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.template = require("../templates/results");

  View.prototype.init = function() {
    this.initialData = this.options.initialData;
    return this.finalData = this.options.finalData;
  };

  View.prototype.getRenderData = function() {
    return {
      error: this.validate()
    };
  };

  View.prototype.validate = function() {
    var error, initialDataLength;
    error = "";
    initialDataLength = _.keys(this.initialData).length;
    if (!(initialDataLength || this.finalData.length)) {
      error = "Please upload both the input data and the resulting data of the community detection algorithm.";
    } else if (!initialDataLength) {
      error = "Please upload the input data file used by the community detection algorithm.";
    } else if (!this.finalData.length) {
      error = "Please upload the outputted communities file before continuing.";
    }
    return error;
  };

  return View;

})(BaseView);
});

;require.register("views/view", function(exports, require, module) {
var $, View, bindingFn,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

$ = jQuery;

bindingFn = function(selector, $) {
  return function(model, val) {
    return $(selector).each(function() {
      var $elem, _ref;
      $elem = $(this);
      if ((_ref = this.tagName) === "INPUT" || _ref === "SELECT") {
        return $elem.val(val);
      } else {
        return $elem.text(val);
      }
    });
  };
};

module.exports = View = (function(_super) {
  __extends(View, _super);

  function View() {
    this.detach = __bind(this.detach, this);
    this.render = __bind(this.render, this);
    this.getRenderData = __bind(this.getRenderData, this);
    this.initialize = __bind(this.initialize, this);
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.init = function() {};

  View.prototype.initialize = function() {
    var triggerSubViews;
    this.subViews = {};
    this.subViewsByType = {};
    triggerSubViews = (function(_this) {
      return function() {
        var key, view, _ref, _results;
        _ref = _this.subViews;
        _results = [];
        for (key in _ref) {
          view = _ref[key];
          _results.push((function(view) {
            var trigger;
            trigger = function() {
              return view.trigger("visible");
            };
            return setTimeout(trigger, 1);
          })(view));
        }
        return _results;
      };
    })(this);
    this.init.apply(this, arguments);
    return this.on("visible", triggerSubViews);
  };

  View.prototype.template = function() {};

  View.prototype.getRenderData = function() {
    if (this.model) {
      return this.model.toJSON();
    }
  };

  View.prototype.className = "main-view";

  View.prototype.render = function() {
    this.$el.html(this.template(this.getRenderData()));
    this.afterRender();
    if (this.bindings && this.model) {
      this.setupBindings();
    }
    return this;
  };

  View.prototype.afterRender = function() {};

  View.prototype.setupBindings = function() {
    var key, val, _ref, _results;
    _ref = this.bindings;
    _results = [];
    for (key in _ref) {
      val = _ref[key];
      _results.push(this.listenTo(this.model, "change:" + key, bindingFn(val, this.$)));
    }
    return _results;
  };

  View.prototype.dispose = function() {
    var id, view, _ref, _ref1, _ref2, _ref3;
    this.trigger("remove");
    this.undelegateEvents();
    this.off();
    if ((_ref = this.model) != null) {
      _ref.off(null, null, this);
    }
    if ((_ref1 = this.collection) != null) {
      _ref1.off(null, null, this);
    }
    if (this.r) {
      this.r.forEach(function(el) {
        return el.off();
      });
    }
    if ($.fn.select2) {
      this.$('select').select2("destroy");
    }
    _ref2 = this.subViews;
    for (id in _ref2) {
      view = _ref2[id];
      view.dispose();
    }
    delete this.subViews;
    this.model = null;
    this.collection = null;
    this.options = null;
    this.remove();
    if ((_ref3 = this.scroller) != null) {
      _ref3.destroy();
    }
    this.scroller = null;
    clearTimeout(this.timer);
    return this;
  };

  View.prototype.modelOn = function(event, callback) {
    return this.model.on(event, callback, this);
  };

  View.prototype.collectionOn = function(event, callback) {
    return this.collection.on(event, callback, this);
  };

  View.prototype.detach = function() {
    return this.$el.detach();
  };

  return View;

})(Backbone.View);
});

;
//# sourceMappingURL=app.js.map