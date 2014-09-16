# Helper function created to map a txt file into an array of communities
###
  Inputs:
  - fileText: the text read from teh file
  - separator: the character used to split entries in the file. it defaults to empty space (" ")

  Outputs:
  - an array of communities
###

module.exports = (fileText, separator = " ") ->
  communities = []
  lines = fileText.split(/\r\n|\r|\n/g)
  for line in lines
    if line.length
      communities.push _.reject(line.split(separator), (val) -> val is "")
  communities