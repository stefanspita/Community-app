BaseView = require "../view"
TableView = require("./tableView")
OptionSelector = require "./optionSelector"

module.exports = class View extends BaseView
  template: require("./templates/viewer")

  events:
    "click .expand":"openDetails"

  init: ->
     Backbone.on "filterReset", =>
      @render()

  getRenderData: ->
    if _.keys(@store.filter.groupings).length
      @communities = _.filter @store.get("finalData"), (comm, index) =>
        index in @store.filter.groupings.communities
    else @communities = false
    {@communities}

  afterRender: ->
    @clearDetails()
    unless _.keys(@store.filter.groupings).length
      @showAllUsers()
    groupingView = new OptionSelector({data:_.keys(@store.filter.groupings), title:"Groupings", key:"groupings"})
    @$(".groupings").html groupingView.render().$el
    groupingView = new OptionSelector({data:@store.filter.attributes, title:"Attributes Filter", key:"attributes", options:@store.get("initialData").header})
    @$(".attributes").html groupingView.render().$el
    groupingView = new OptionSelector({data:_.keys(@store.filter.filters), title:"Filters", key:"filters", options:@store.get("initialData").header, values:true})
    @$(".dataFilter").html groupingView.render().$el

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
    detailView = new TableView({persons:_.omit(@store.get("initialData"), "header")})
    @$(".details").html detailView.render().$el
    @$(".details").show()
