BaseView = require "../view"

module.exports = class View extends BaseView
  template: require("./templates/tableView")

  init: ->
    @persons = _.toArray @options.persons

  getRenderData: ->
    {persons:_.first(@persons, 20), headers:@store.get("initialData").header}
