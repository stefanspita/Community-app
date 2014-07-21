BaseView = require "../view"
forceInt = require "../../libs/forceInt"
possibleValues = require "../../data/possibleValues"
answerTypes = require "../../data/answerTypes"
tableTemplate = require("./templates/table")

module.exports = class View extends BaseView
  template: require("./templates/tableView")

  events:
    "click .header": "sortBy"

  init: ->
    @persons = _.toArray @options.persons
    @headers = @store.get("initialData").header
    @displayRows = _.first(@persons, 15)

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
    @$(".table").html tableTemplate {@displayRows, @headers, sorter:forceInt(_.keys(@store.filter.sorter)[0]), order:_.values(@store.filter.sorter)[0]}

  afterRender: ->
    @$(".attribute").hover(@setTooltip, @unsetTooltip)
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
    @render()
