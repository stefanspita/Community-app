# See docs at http://brunch.readthedocs.org/en/latest/config.html.
exports.config =
  files:
    javascripts:
      defaultExtension: "coffee"
      joinTo:
        "scripts/app.js": /^app/
        "scripts/vendor.js": /^vendor/

      order:
        before: [
          "vendor/scripts/jquery-2.0.3.min.js"
          "vendor/scripts/d3.v3.js"
          "vendor/scripts/underscore-1.5.2.min.js"
          "vendor/scripts/backbone-1.0.0.min.js"
        ]

    templates:
      defaultExtension: "hbs"
      joinTo: "scripts/app.js"

  addSourceURLs: true
  sourceMaps: false