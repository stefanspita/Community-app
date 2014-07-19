BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("./templates/tableView")

  init: ->
    @persons = _.toArray @options.persons

  getRenderData: ->
    {@persons, headers:@store.get("initialData").header}

  afterRender: ->
    table = @$("table")[0]
    sorttable.makeSortable(table)


