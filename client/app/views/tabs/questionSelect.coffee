BaseView = require "../view"
possibleValues = require "../../data/possibleValues"

module.exports = class View extends BaseView
  template: require("./templates/select")

  getRenderData: ->
    if @options.excluded
      vals = _.omit possibleValues, @options.excluded
    else vals = possibleValues
    options = _.map vals, (question, key) ->
      {value:key, label:key, title:question.question}
    _.extend @options, {options}