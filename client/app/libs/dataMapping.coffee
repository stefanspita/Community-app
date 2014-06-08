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
      finalLine = {}
      for value, index in localLine
        unless index is 0
          finalLine[header[index]] = value
      communities[localLine[0]] = finalLine
  communities