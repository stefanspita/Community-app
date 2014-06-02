module.exports = (fileText) ->
  communities = []
  lines = fileText.split(/\r\n|\r|\n/g)
  for line in lines
    if line.length
      communities.push {nodes:line.split(" ")}
  communities