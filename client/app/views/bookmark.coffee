module.exports = Bookmark = Backbone.View.extend
  tagName: "li"
  template: require("../templates/bookmark")
  events:
    "click a.delete": "deleteBookmark"

  render: ->
    @$el.html @template(bookmark: @model.toJSON())
    return

  deleteBookmark: ->
    @model.destroy()
    @remove()
    return
