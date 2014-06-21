module.exports = (str) ->
  str = "#{str}".replace(/,/g,"").replace(/\s/g,"").replace(/%/g,"")
  out = Math.round str
  out = 0 if _.isNaN(out)
  out