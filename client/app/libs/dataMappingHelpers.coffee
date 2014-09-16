# questionnaire data mapping to an object containing person ids as keys and the array of their answers as values

module.exports =
  ###
    Inputs:
    - personList: the array of people fetched from the database

    Outputs:
    - an object containing person ids as keys and the array of their answers as values, having _id property created by the database excluded
  ###
  dataMapping: (personList) ->
    people = {}
    for person in personList
      _.extend people, person
    people = _.omit people, "_id"
    people

  ###
    Inputs:
    - fileText: text read from the questionnaire data file
    - separator: field separator for the file, default is set to empty space (" ")
    - header: a flag to be set if the first line of the file are headers

    Outputs:
    - an array of respondents and their answers for every question
  ###
  dbDataMapping: (fileText, separator = " ", header = false) ->
    people = []
    lines = fileText.split(/\r\n|\r|\n/g)
    if header
      header = lines[0]
      header = header.split(separator)
      lines.splice(0, 1)
    for line in lines
      if line.length
        person = {}
        localLine = line.split(separator)
        person[localLine[0]] = localLine
        people.push person
    people.push {header}
    people