BookmarkView = require("./bookmark")
module.exports = AppView = Backbone.View.extend
  el: "body"
  template: require("../templates/home")
  events:
    "click #add-bookmark": "createBookmark"


# initialize is automatically called once after the view is constructed
  initialize: ->
    @listenTo @collection, "add", @onBookmarkAdded
    return

  render: ->

    # we render the template
    @$el.html @template()

    # fetch the bookmarks from the database
    @collection.fetch()
    return

  createBookmark: (event) ->

    # submit button reload the page, we don't want that
    event.preventDefault()

    # add it to the collection
    @collection.create
      title: @$el.find("input[name=\"title\"]").val()
      url: @$el.find("input[name=\"url\"]").val()

    return

  onBookmarkAdded: (bookmark) ->

    # render the specific element
    bookmarkView = new BookmarkView(model: bookmark)
    bookmarkView.render()
    @$el.find("ul").append bookmarkView.$el
    return
