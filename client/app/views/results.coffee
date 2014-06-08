BaseView = require "./view"

module.exports = class View extends BaseView
  template: require("../templates/results")

  init: ->
    @initialData = @options.initialData
    @finalData = @options.finalData

  getRenderData: ->
    {error:@validate()}

  validate: ->
    error = ""
    initialDataLength = _.keys(@initialData).length
    unless initialDataLength or @finalData.length
      error = "Please upload both the input data and the resulting data of the community detection algorithm."
    else unless initialDataLength
      error = "Please upload the input data file used by the community detection algorithm."
    else unless @finalData.length
      error = "Please upload the outputted communities file before continuing."
    error