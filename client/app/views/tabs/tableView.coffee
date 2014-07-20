BaseView = require "../view"
forceInt = require "../../libs/forceInt"
possibleValues = require "../../data/possibleValues"
answerTypes = require "../../data/answerTypes"

module.exports = class View extends BaseView
  template: require("./templates/tableView")

  events:
    "click .header": "sortBy"

  init: ->
    @persons = _.toArray @options.persons
    @headers = @store.get("initialData").header

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

  getRenderData: ->
    {persons:_.first(@persons, 20), @headers, sorter:forceInt(_.keys(@store.filter.sorter)[0]), order:_.values(@store.filter.sorter)[0]}

  afterRender: ->
    @$(".attribute").hover(@setTooltip, @unsetTooltip)

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
    @render()
