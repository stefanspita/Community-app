BaseView = require "../view"
TableView = require("./tableView")

module.exports = class View extends BaseView
  template: require("./templates/viewer")

  events:
    "click .expand":"openDetails"

  init: ->
    @filter = {}
    if @options.communities
      @filter.communities = @options.communities

  getRenderData: ->
    if @filter.communities
      @communities = _.filter @store.get("finalData"), (comm, index) =>
        index in @filter.communities
    else @communities = @store.get("finalData")
    {@communities}

  afterRender: ->
    @clearDetails()

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


