module.exports =
  dataMapping: (personList) ->
    people = {}
    for person in personList
      _.extend people, person
    people = _.omit people, "_id"
    people

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