# helper function, which turns a string formed of a number, into an actual number, or 0 if the string does not contain a number

module.exports = (str) ->
  str = "#{str}".replace(/,/g,"").replace(/\s/g,"").replace(/%/g,"")
  out = Math.round str
  out = 0 if _.isNaN(out)
  out