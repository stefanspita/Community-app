module.exports = (fileText, separator = " ") ->
  communities = []
  lines = fileText.split(/\r\n|\r|\n/g)
  for line in lines
    if line.length
      communities.push _.reject(line.split(separator), (val) -> val is "")
  communities