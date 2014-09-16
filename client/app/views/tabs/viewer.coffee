# a placeholder for the table view is defined in this file
# the filters are applied at this stage, to only send the respondents matching them

BaseView = require "../view"
TableView = require("./tableView")
OptionSelector = require "./optionSelector"
FilterSelector = require "./filterSelector"

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

    # filter views are defined here
    groupingView = new OptionSelector({data:_.keys(@store.filter.groupings), title:"Data Grouping", key:"groupings"})
    @$(".groupings").html groupingView.render().$el
    groupingView = new OptionSelector({data:@store.filter.attributes, title:"Question Filter", key:"attributes", editable:true})
    @$(".attributes").html groupingView.render().$el
    groupingView = new FilterSelector({title:"Attribute Filter", key:"filters"})
    @$(".dataFilter").html groupingView.render().$el

  clearDetails: ->
    @$(".details").empty()
    @$(".details").hide()

  # this function is called when the user clicks on the "details" button to see the members of a community
  openDetails: (e) ->
    @clearDetails()
    index = $(e.target).data("index")
    community = @communities[index]
    initialData = @store.get("initialData")
    persons = _.pick initialData, community
    if _.keys(@store.filter.filters).length
      persons = @filterPeople(persons)
    detailView = new TableView({persons})
    @$("##{index}").html detailView.render().$el
    @$("##{index}").show()

  showAllUsers: ->
    persons = _.omit(@store.get("initialData"), "header")
    if _.keys(@store.filter.filters).length
      persons = @filterPeople(persons)
    detailView = new TableView({persons})
    @$(".details").html detailView.render().$el
    @$(".details").show()

  filterPeople: (list) ->
    for key, val of @store.filter.filters
      ind = _.indexOf @store.get("initialData").header, key
      list = _.filter list, (person) ->
        person[ind] is val
    list
