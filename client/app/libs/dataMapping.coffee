module.exports = (fileText, separator = " ", header = false) ->
  communities = {}
  lines = fileText.split(/\r\n|\r|\n/g)
  if header
    header = lines[0]
    header = header.split(separator)
    lines.splice(0, 1)
  for line in lines
    if line.length
      localLine = line.split(separator)
      key = "#{localLine[0]}#{localLine[1]}"
      communities[key] = localLine
  communities["header"] = header
  communities