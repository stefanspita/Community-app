path = "http://localhost:3000/"

module.exports = ->

  request = (url, data, method, cb) ->
    req =
      dataType: "json"
      url: "#{path}#{url}"
      data: JSON.stringify(data)
      success: (result) ->
        err = if result then null else "No Data"
        cb err, result
      error: (error) ->
        cb(error)

    if method
      req.method = method
      req.type = method
    else req.method = "GET"

    $.ajaxSetup
      async: true
    $.ajax req

  return request
