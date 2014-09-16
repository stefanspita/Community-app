# the table view is defined here
# more specific options like sorting, paging and tooltip setting on the individual elements are implemented

BaseView = require "../view"
forceInt = require "../../libs/forceInt"
possibleValues = require "../../data/possibleValues"
answerTypes = require "../../data/answerTypes"
tableTemplate = require("./templates/table")

module.exports = class View extends BaseView
  template: require("./templates/tableView")

  events:
    "click .header": "sortBy"
    "click a.communityGouping":"communityGouping"

  init: ->
    @persons = _.toArray @options.persons
    @headers = @store.get("initialData").header
    @displayRows = _.first(@persons, 15)
    @finaldata = @store.get("finalData")

  communityGouping: (e) ->
    person = $(e.target).data("person")
    communities = []
    for comm, index in @finaldata
      if person in comm
        communities.push index
    @store.filter.groupings = {communities}
    Backbone.trigger "communitiesFiltered"

  setTooltip: (e) =>
    ind = $(e.target).data("index")
    header = @headers[ind]
    if $(e.target).hasClass("header")
      title = possibleValues[header]?.question
      unless title then title = $(e.target).text()
    else
      answersType = possibleValues[header]?.answersType
      answer = $(e.target).text()
      if answersType
        title = answerTypes[answersType][answer]
      unless title then title = answer
    $(e.target).attr( "title", title )

  unsetTooltip: (e) ->
    $(e.target).removeAttr( "title" )

  updateTableView: =>
    if @store.filter.attributes.length
      attributes = _.map @store.filter.attributes, (header) =>
        _.indexOf @headers, header
      attributes.push 0
    else attributes = [0..683]
    @displayRows = _.map @displayRows, (row) =>
      unless  @store.filter.groupings.communities
        person = row[0]
        found = _.find @finaldata, (comm) ->
          person in comm
        if found
          communityRow = """<a href="javascript:void(0)" data-person="#{person}" class="communityGouping">See Communities</a>"""
      {row, communityRow}
    @$(".table").html tableTemplate {@displayRows, @headers, sorter:forceInt(_.keys(@store.filter.sorter)[0]), order:_.values(@store.filter.sorter)[0], attributes}
    @$(".attribute").hover(@setTooltip, @unsetTooltip)

  afterRender: ->
    @updateTableView()
    if @persons.length > 15
      @$("#pager").pagination
        items:@persons.length
        itemsOnPage:15
        cssStyle: 'light-theme'
        onPageClick:@pageChange

  pageChange: (pageNumber) =>
    pageNumber -= 1
    @displayRows = @persons.slice(pageNumber * 15, pageNumber * 15 + 15)
    @updateTableView()

  sortBy: (e) =>
    ind = $(e.target).data("index")
    if @store.filter.sorter[ind]
      if @store.filter.sorter[ind] is "asc"
        @store.filter.sorter[ind] = "desc"
      else @store.filter.sorter[ind] = "asc"
    else
      @store.filter.sorter = {}
      @store.filter.sorter[ind] = "asc"
    @persons = _.sortBy @persons, (person) =>
      if @store.filter.sorter[ind] is "desc"
        return -1 * forceInt(person[ind])
      else return forceInt(person[ind])
    @displayRows = _.first(@persons, 15)
    @updateTableView()
