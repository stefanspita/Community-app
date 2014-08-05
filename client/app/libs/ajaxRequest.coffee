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
