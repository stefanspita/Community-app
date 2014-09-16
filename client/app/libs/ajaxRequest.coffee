# JQuery AJAX functions used to send or request data data from the server.
###
  Inputs:
  - url: the custom url matching one of the url listeners on the server
  - data: data to be sent. If undefined, nothing is being sent
  - method: GET or POST
  - cb: callback function, which gets called when the request is fulfilled by the server

  Outputs:
  - a configured function, which gets called in the view, when a client requests it
###

path = "http://localhost:3000/"

module.exports = ->

  request = (url, data, method, cb) ->
    req =
      dataType: "json"
      url: "#{path}#{url}"
      success: (result) ->
        err = if result then null else "No Data"
        cb err, result
      error: (error) ->
        cb(error)

    if method
      req.method = method
      req.type = method
    else req.method = "GET"
    if data
      req.data = JSON.stringify(data)

    $.ajaxSetup
      async: true
    $.ajax req

  return request
