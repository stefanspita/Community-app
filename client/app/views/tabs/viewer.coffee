BaseView = require "../view"
TableView = require("./tableView")

module.exports = class View extends BaseView
  template: require("./templates/viewer")

  events:
    "click .expand":"openDetails"

  init: ->
    @store.filter ?= {groupings:[], filters:[], attributes:[]}
    if @options.communities
      @store.filter.groupings.push {communities: @options.communities }

  getRenderData: ->
    if @store.filter.groupings.length
      @communities = _.filter @store.get("finalData"), (comm, index) =>
        index in @store.filter.communities
    else @communities = false
    {@communities}

  afterRender: ->
    @clearDetails()
    unless @store.filter.groupings.length
      @showAllUsers()

  clearDetails: ->
    @$(".details").empty()
    @$(".details").hide()

  openDetails: (e) ->
    @clearDetails()
    index = $(e.target).data("index")
    community = @communities[index]
    initialData = @store.get("initialData")
    persons = _.pick initialData, community
    detailView = new TableView({persons})
    @$("##{index}").html detailView.render().$el
    @$("##{index}").show()

  showAllUsers: ->
    detailView = new TableView({persons:@store.get("initialData")})
    @$(".details").html detailView.render().$el
    @$(".details").show()
