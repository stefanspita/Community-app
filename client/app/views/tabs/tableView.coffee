BaseView = require "../view"
forceInt = require "../../libs/forceInt"

module.exports = class View extends BaseView
  template: require("./templates/tableView")

  events:
    "click .header": "sortBy"

  init: ->
    @persons = _.toArray @options.persons
    @headers = @store.get("initialData").header

  getRenderData: ->
    console.log _.keys(@store.filter.sorter)[0], _.values(@store.filter.sorter)[0]
    {persons:_.first(@persons, 20), @headers, sorter:forceInt(_.keys(@store.filter.sorter)[0]), order:_.values(@store.filter.sorter)[0]}

  sortBy: (e) ->
    header = $(e.target).data("key")
    ind = _.indexOf @headers, header
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
