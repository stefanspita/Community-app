BaseView = require "../view"
possibleValues = require "../../data/possibleValues"

module.exports = class View extends BaseView
  template: require("./templates/select")
  tagName:"span"

  getRenderData: ->
    if @options.excluded
      vals = _.omit possibleValues, @options.excluded
    else if @options.included
      if @options.sorter
        @options.included = _.sortBy @options.included, (opt) =>
          -1 * opt.probability[@options.sorter]
      included = _.pluck @options.included, "question"
      vals = _.pick possibleValues, included
    else vals = possibleValues
    @options.options = _.map vals, (question, key) =>
      label = key
      if @options.sorter
        suffix = "non-random probability"
        if @options.sorter is "total"
          suffix = "correlation probability"
        data = _.findWhere(@options.included, {question:key})
        label = "#{key} - #{suffix}: #{data?.probability?[@options.sorter]?.toFixed(2)}%"
      {value:key, label, title:question.question}
    @options