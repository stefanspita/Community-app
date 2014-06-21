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

;require.register("charts/barsLine", function(exports, require, module) {
var colors, defaults;

defaults = {
  width: 700,
  height: 350,
  margin: {
    top: 10,
    right: 10,
    bottom: 50,
    left: 40
  },
  margin2: {
    top: 330,
    right: 10,
    bottom: 20,
    left: 40
  },
  xKey: "date",
  yKey: "balance",
  data: [],
  eventData: [],
  eventChange: function() {},
  onClick: function() {},
  processData: function(raw) {
    var item, line, minus, plus, year, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = raw.length; _i < _len; _i++) {
      item = raw[_i];
      plus = item.plus;
      minus = item.minus;
      year = item.year;
      line = item.line;
      _results.push({
        plus: plus,
        minus: minus,
        year: year,
        line: line
      });
    }
    return _results;
  }
};

colors = require("./colors");

module.exports = function(opts) {
  var blue1, blue2, blues, color, colorInterpolate, colorRed, colorScale, colorScaleMinus, data, defaultWidth, draw, focus, formatPercent, height, line, margin, margin2, max, maxTicks, min, minus, netLine, options, plus, red1, red2, redInterpolate, reds, skip, svg, width, xAxis, xbar, xg, xpad, y, yAxis, yExtent, year, years, yg, _ref, _ref1, _ref2, _ref3;
  defaultWidth = 700;
  options = _.extend({}, defaults, {
    width: defaultWidth
  }, opts);
  margin = options.margin, margin2 = options.margin2;
  if (options.yKey2) {
    margin.right = 40;
  }
  width = options.width - margin.left - margin.right;
  height = options.height - margin.top - margin.bottom;
  formatPercent = d3.format("s");
  xbar = d3.scale.ordinal().rangeRoundBands([0, width], .1);
  y = d3.scale.linear().range([height, 0.]);
  blues = colors.blue;
  blue1 = (_ref = opts.blue1) != null ? _ref : blues[0];
  blue2 = (_ref1 = opts.blue2) != null ? _ref1 : blues[4];
  colorInterpolate = d3.interpolateRgb(blue1, blue2);
  colorScale = d3.scale.linear().range([1, 0]);
  colorScaleMinus = d3.scale.linear().range([1, 0]);
  color = function(y) {
    return colorInterpolate(colorScale(y));
  };
  reds = colors.orange;
  red1 = (_ref2 = opts.red1) != null ? _ref2 : reds[0];
  red2 = (_ref3 = opts.red2) != null ? _ref3 : reds[2];
  redInterpolate = d3.interpolateRgb(red1, red2);
  colorRed = function(y) {
    return redInterpolate(colorScaleMinus(y));
  };
  xAxis = d3.svg.axis().scale(xbar).orient("bottom").tickSize(6);
  yAxis = d3.svg.axis().scale(y).orient("left").tickFormat(formatPercent).ticks(5);
  svg = d3.select(options.elem).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom);
  svg.append("defs").append("clipPath").attr("id", "clip").append("rect").attr("width", width + 50).attr("height", height);
  focus = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  data = options.processData(options.data);
  years = _.pluck(data, "year");
  xbar.domain(years);
  maxTicks = 20;
  if (years.length > maxTicks) {
    skip = Math.round(years.length / maxTicks);
    xAxis.tickValues((function() {
      var _i, _len, _results;
      _results = [];
      for ((skip > 0 ? (_i = 0, _len = years.length) : _i = years.length - 1); skip > 0 ? _i < _len : _i >= 0; _i += skip) {
        year = years[_i];
        _results.push(year);
      }
      return _results;
    })());
  }
  max = d3.max(data, d3.get("plus"));
  min = d3.min(data, d3.get("minus"));
  yExtent = [min, max];
  y.domain(yExtent);
  colorScale.domain([0, max]);
  colorScaleMinus.domain([min, 0]);
  plus = focus.selectAll(".plus").data(data).enter().append("rect").attr("class", "plus").attr("x", function(d) {
    return xbar(d.year);
  }).attr("width", xbar.rangeBand()).attr("y", function(d) {
    return y(0);
  }).attr("height", 0).attr("fill", function(d) {
    return color(d.plus);
  }).on("click", options.onClick);
  minus = focus.selectAll(".minus").data(data).enter().append("rect").attr("class", "minus").attr("x", function(d) {
    return xbar(d.year);
  }).attr("width", xbar.rangeBand()).attr("y", function(d) {
    return y(0);
  }).attr("height", 0).attr("fill", function(d) {
    return colorRed(d.minus);
  }).on("click", options.onClick);
  (draw = function() {
    plus.transition().delay(function(d, i) {
      return i * 50;
    }).duration(1000).attr("y", function(d) {
      return y(d.plus);
    }).attr("height", function(d) {
      return y(0) - y(d.plus);
    });
    return minus.transition().delay(function(d, i) {
      return i * 50;
    }).duration(1000).attr("y", y(0)).attr("height", function(d) {
      return y(d.minus) - y(0);
    });
  })();
  xg = focus.append("g").attr("class", "x axis withRect").attr("transform", "translate(0," + y(0) + ")").call(xAxis);
  xg.selectAll("g").insert("rect", "text").attr("width", 55).attr("height", 14).attr("x", -58).attr("rx", 3).attr("ry", 3).attr("fill", "#66E0FF").attr("transform", "rotate(-45)");
  xg.selectAll("text").style("text-anchor", "end").attr("dx", "-.8em").attr("dy", ".15em").attr("transform", "rotate(-45)");
  yg = focus.append("g").attr("class", "y axis").call(yAxis);
  if (options.line) {
    xpad = xbar.rangeBand() / 2;
    line = d3.svg.line().x(function(d) {
      return xpad + xbar(d.year);
    }).y(d3.get("line", y));
    netLine = focus.append("path").datum(data).attr("d", line).attr("class", "line").style("stroke", "#506930").style("stroke-width", "5px");
  }
  return function(freshData) {
    if (_.isFunction(freshData)) {
      data = freshData(options.data);
    } else {
      data = options.processData(freshData);
    }
    max = d3.max(data, d3.get("plus"));
    min = d3.min(data, d3.get("minus"));
    yExtent = [min, max];
    y.domain(yExtent);
    colorScale.domain([0, max]);
    colorScaleMinus.domain([min, 0]);
    plus.data(data).transition().duration(1000).delay(function(d, i) {
      return i * 50;
    }).attr("y", function(d) {
      return y(d.plus);
    }).attr("height", function(d) {
      return y(0) - y(d.plus);
    }).attr("fill", function(d) {
      return color(d.plus);
    });
    minus.data(data).transition().duration(1000).delay(function(d, i) {
      return i * 50;
    }).attr("y", y(0)).attr("height", function(d) {
      return y(d.minus) - y(0);
    }).attr("fill", function(d) {
      return colorRed(d.minus);
    });
    xg.transition().duration(1000).attr("transform", "translate(0," + y(0) + ")");
    yg.transition().duration(1000).call(yAxis);
    if (netLine) {
      return netLine.datum(data).transition().duration(2000).attr("d", line);
    }
  };
};
});

;require.register("charts/colors", function(exports, require, module) {
var all, allColors, blue, color, colors, green, grey, i, key, mix, mix2, orange, red, stacked, _i, _j, _k, _len, _len1, _ref, _ref1;

grey = "#404040,#4b4b4b,#575757,#646464,#717171".split(",");

blue = "#3e7ba1,#478eba,#51a2d4,#5fbdf9,#6dd8ff".split(",");

green = "#506930,#5c7837,#698a3f,#7ca14a,#8db854".split(",");

orange = "#ff6c00,#ff8e00,#ff8e00,#ffa500,#ffbc00".split(",");

red = "#A13E3E,#BA4747,#D45151,#F95F5F,#FF6D6D".split(",");

stacked = "#ff8e00,#51a2d4,#ff6c00,#3e7ba1,#ffa500,#5fbdf9,#ff8e00,#51a2d4,#ff6c00,#3e7ba1,#ffa500,#5fbdf9".split(",");

allColors = {
  orange: orange,
  blue: blue,
  green: green,
  red: red,
  grey: grey
};

all = [].concat(blue, green, orange, red, grey);

mix = [];

mix2 = [];

_ref = [2, 3, 4, 1, 0];
for (_i = 0, _len = _ref.length; _i < _len; _i++) {
  i = _ref[_i];
  _ref1 = ["green", "blue", "orange", "grey", "red"];
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    color = _ref1[_j];
    mix.push(allColors[color][i]);
  }
}

for (i = _k = 2; _k <= 4; i = ++_k) {
  for (key in allColors) {
    colors = allColors[key];
    if (key !== "grey") {
      mix2.push(colors[i]);
    }
  }
}

allColors.mix = mix;

allColors.mix2 = mix2;

allColors.orangeBlue = [orange[0]].concat(blue);

allColors.spectral = ["#9e0142", "#d53e4f", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#e6f598", "#abdda4", "#66c2a5", "#3288bd", "#5e4fa2"];

allColors.spectral2 = ["#a50026", "#d73027", "#f46d43", "#fdae61", "#fee08b", "#ffffbf", "#d9ef8b", "#a6d96a", "#66bd63", "#1a9850", "#006837"];

allColors.spectral3 = ["#fcfbfd", "#efedf5", "#dadaeb", "#bcbddc", "#9e9ac8", "#807dba", "#6a51a3", "#54278f", "#3f007d", "#fff5eb", "#fee6ce", "#fdd0a2", "#fdae6b", "#fd8d3c", "#f16913", "#d94801", "#a63603", "#7f2704"];

allColors.mix3 = stacked;

module.exports = allColors;
});

;require.register("collections/bookmarks", function(exports, require, module) {
var Bookmark, Bookmarks;

Bookmark = require("../models/bookmark");

module.exports = Bookmarks = Backbone.Collection.extend({
  model: Bookmark,
  url: "bookmarks"
});
});

;require.register("data/possibleValues", function(exports, require, module) {
module.exports = {
  cct1000: [-1, 1, 2],
  cct1001: [-1, 1, 2],
  cct1002: [-1, 1, 2],
  cct1003: [-1, 1, 2],
  cct1004: [-1, 1, 2],
  cct1005: [-1, 1, 2],
  cct1006: [-1, 1, 2],
  cct1007: [-1, 1, 2],
  cct1008: [-1, 1, 2],
  cct1009: [-1, 1, 2],
  cct1010: [-1, 1, 2],
  cct1011: [-1, 1, 2]
};
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
  var communities, line, lines, localLine, _i, _len;
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
      communities[localLine[0]] = localLine;
    }
  }
  communities["header"] = header;
  return communities;
};
});

;require.register("libs/forceInt", function(exports, require, module) {
module.exports = function(str) {
  var out;
  str = ("" + str).replace(/,/g, "").replace(/\s/g, "").replace(/%/g, "");
  out = Math.round(str);
  if (_.isNaN(out)) {
    out = 0;
  }
  return out;
};
});

;require.register("libs/tempViews", function(exports, require, module) {
module.exports = {};
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


  return "<h1>Community Visualization App</h1>\r\n\r\n<div class=\"box\">\r\n    <label>Please Choose the data file:</label>\r\n    <br />\r\n    <input type=\"file\" name=\"files\" id=\"initial\" />\r\n</div>\r\n\r\n<div class=\"box\">\r\n    <label>Please Choose the communities file:</label>\r\n    <br />\r\n    <input type=\"file\" name=\"files\" id=\"final\" />\r\n</div>\r\n\r\n<h2>Results</h2>\r\n<div id=\"resultsTemplate\"></div>";});
});

require.register("templates/home", function(exports, require, module) {
module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var foundHelper, self=this;


  return "<h1>Welcome on My Own Bookmarks</h1>\r\n<p>This application will help you manage your bookmarks!</p>\r\n<form>\r\n    <label>Title:</label>\r\n    <input type=\"text\" name=\"title\"/>\r\n    <label>Url:</label>\r\n    <input type=\"text\" name=\"url\"/>\r\n    <input id=\"add-bookmark\" type=\"submit\" value=\"Add a new bookmark\"/>\r\n</form>\r\n<ul></ul>";});
});

require.register("templates/option", function(exports, require, module) {
module.exports = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  helpers = helpers || Handlebars.helpers;
  var buffer = "", stack1, stack2, foundHelper, tmp1, self=this, functionType="function", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;

function program1(depth0,data) {
  
  var buffer = "", stack1;
  buffer += "\r\n        <option value=\"";
  stack1 = depth0;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, ".", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\">";
  stack1 = depth0;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, ".", { hash: {} }); }
  buffer += escapeExpression(stack1) + "</option>\r\n    ";
  return buffer;}

  buffer += "<select name=\"";
  foundHelper = helpers.name;
  stack1 = foundHelper || depth0.name;
  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }
  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, "name", { hash: {} }); }
  buffer += escapeExpression(stack1) + "\">\r\n    <option value=\"\"></option>\r\n    ";
  foundHelper = helpers.headers;
  stack1 = foundHelper || depth0.headers;
  stack2 = helpers.each;
  tmp1 = self.program(1, program1, data);
  tmp1.hash = {};
  tmp1.fn = tmp1;
  tmp1.inverse = self.noop;
  stack1 = stack2.call(depth0, stack1, tmp1);
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "\r\n</select>\r\n";
  return buffer;});
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
  buffer += "\r\n<form class=\"options\"></form>\r\n";
  buffer += "\r\n\r\n<div id=\"graph\"></div>";
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
    return this.$el.find("#resultsTemplate").html(resultsView.render().$el);
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

;require.register("views/option", function(exports, require, module) {
var BaseView, View,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require("./view");

module.exports = View = (function(_super) {
  __extends(View, _super);

  function View() {
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.template = require("../templates/option");

  View.prototype.events = {
    "click a.delete": "deleteOption"
  };

  View.prototype.init = function() {};

  View.prototype.getRenderData = function() {
    return this.options;
  };

  View.prototype.deleteOption = function() {
    this.remove();
    Backbone.trigger('filterOption:removed');
  };

  return View;

})(BaseView);
});

;require.register("views/results", function(exports, require, module) {
var BarsLine, BaseView, OptionView, View, dataMap, forceInt, getSummary, possibleValues,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require("./view");

OptionView = require("./option");

forceInt = require("../libs/forceInt");

BarsLine = require("../charts/barsLine");

possibleValues = require("../data/possibleValues");

getSummary = function(results, indexes, headers) {
  var h, i, r, summary, val, _i, _len, _ref;
  i = indexes[0];
  h = headers[i];
  summary = [];
  _ref = possibleValues[h];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    val = _ref[_i];
    r = _.countBy(results, function(community) {
      if (community.attributesSet > 2) {
        return (forceInt(community.attributeVals["" + i]["" + val]) / community.attributesSet * 100).toFixed(2);
      } else {
        return false;
      }
    });
    summary.push({
      val: val,
      count: r
    });
  }
  return summary;
};

dataMap = function(result) {
  var a, b, final, _ref;
  final = [];
  _ref = result.count;
  for (a in _ref) {
    b = _ref[a];
    if (a !== "false") {
      final.push({
        plus: b,
        minus: 0,
        year: a
      });
    }
  }
  final = _.sortBy(final, function(v) {
    return forceInt(v.year);
  });
  return final;
};

module.exports = View = (function(_super) {
  __extends(View, _super);

  function View() {
    this.getCorrelationPercentages = __bind(this.getCorrelationPercentages, this);
    this.afterRender = __bind(this.afterRender, this);
    return View.__super__.constructor.apply(this, arguments);
  }

  View.prototype.template = require("../templates/results");

  View.prototype.events = {
    "click #addOption": "addOption",
    "change select": "updateData"
  };

  View.prototype.init = function() {
    this.initialData = this.options.initialData;
    this.finalData = this.options.finalData;
    this.optionCount = 0;
    return this.listenTo(Backbone, 'filterOption:removed', this.updateData);
  };

  View.prototype.getRenderData = function() {
    return {
      error: this.validate()
    };
  };

  View.prototype.afterRender = function() {
    if (this.validate() === "") {
      this.$("addOption").show();
      return this.addOption();
    }
  };

  View.prototype.updateData = function() {
    var correlationResults, data, indexes, val, _i, _len, _results;
    data = this.$("form").serializeArray();
    indexes = this.getIndexes(data);
    correlationResults = this.getCorrelationPercentages(indexes);
    correlationResults = getSummary(correlationResults, indexes, this.initialData.header);
    this.$('#graph').empty();
    _results = [];
    for (_i = 0, _len = correlationResults.length; _i < _len; _i++) {
      val = correlationResults[_i];
      this.$('#graph').append(" <h3>Number of communities matching value " + val.val + "</h3> ");
      _results.push(BarsLine({
        data: val,
        elem: this.$('#graph')[0],
        processData: dataMap
      }));
    }
    return _results;
  };

  View.prototype.getCorrelationPercentages = function(indexes) {
    var attributeVals, attributesSet, community, correlationResults, i, index, _i, _j, _len, _len1, _ref;
    correlationResults = [];
    _ref = this.finalData;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      community = _ref[index];
      attributesSet = _.countBy(community, (function(_this) {
        return function(node) {
          var i, _j, _len1;
          if (_this.initialData[node]) {
            for (_j = 0, _len1 = indexes.length; _j < _len1; _j++) {
              i = indexes[_j];
              if (_this.initialData[node][i] > -10) {
                return true;
              }
            }
          }
          return false;
        };
      })(this));
      attributeVals = {};
      for (_j = 0, _len1 = indexes.length; _j < _len1; _j++) {
        i = indexes[_j];
        attributeVals["" + i] = _.countBy(community, (function(_this) {
          return function(node) {
            if (_this.initialData[node]) {
              return _this.initialData[node][i];
            } else {
              return false;
            }
          };
        })(this));
      }
      correlationResults.push({
        totalNodes: community.length,
        attributesSet: forceInt(attributesSet["true"]),
        attributeVals: attributeVals
      });
    }
    return correlationResults;
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

  View.prototype.addOption = function() {
    var optionView;
    this.optionCount += 1;
    optionView = new OptionView({
      name: "option" + this.optionCount,
      headers: this.initialData.header
    });
    return this.$el.find("form").append(optionView.render().$el);
  };

  View.prototype.getIndexes = function(data) {
    var index, indexes, option, _i, _len;
    indexes = [];
    for (index = _i = 0, _len = data.length; _i < _len; index = ++_i) {
      option = data[index];
      if (option.value) {
        indexes.push(_.indexOf(this.initialData.header, option.value));
      }
    }
    return indexes;
  };

  return View;

})(BaseView);
});

;require.register("views/view", function(exports, require, module) {
var $, View, bindingFn, tempViews,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

tempViews = require('../libs/tempViews');

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
    this.renderTempViews();
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

  View.prototype.renderTempViews = function() {
    var view;
    view = this;
    return this.$('view').each(function() {
      var SubView, elem, id, subView, viewData, _base, _name;
      elem = $(this);
      id = elem.attr("data-id");
      viewData = tempViews[id];
      SubView = _.require(viewData.viewName, "views/" + viewData.viewName, "BSM/views/" + viewData.viewName);
      if (_.isFunction(SubView)) {
        view.subViews[id] = subView = new SubView(_.extend({}, view.options, viewData.data));
        if ((_base = view.subViewsByType)[_name = viewData.viewName] == null) {
          _base[_name] = [];
        }
        view.subViewsByType[viewData.viewName].push(subView);
        return elem.replaceWith(subView.el);
      } else {
        return console.warn("Invalid subview data", viewData);
      }
    });
  };

  return View;

})(Backbone.View);
});

;
//# sourceMappingURL=app.js.map