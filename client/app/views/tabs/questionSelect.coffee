BaseView = require "../view"
possibleValues = require "../../data/possibleValues"

module.exports = class View extends BaseView
  template: require("./templates/select")

  getRenderData: ->
    if @options.excluded
      vals = _.omit possibleValues, @options.excluded
    else if @options.included
      vals = _.pick possibleValues, @options.included
    else vals = possibleValues
    @options.options = _.map vals, (question, key) ->
      {value:key, label:key, title:question.question}
    @options