BaseView = require "../view"
detailTemplate = require("./templates/personList")

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
    @$(".details").hide()

  openDetails: (e) ->
    @$(".details").hide()
    index = $(e.target).data("index")
    community = @communities[index]
    initialData = @store.get("initialData")
    persons = _.pick initialData, community
    @$("##{index}").html detailTemplate({persons, headers:initialData.header})
    @$("##{index}").show()


