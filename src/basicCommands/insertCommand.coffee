Command = require("../interface/command")

class InsertCommand extends Command

  constructor: (@model) ->
    @name = "InsertCommand for #{@model.name}"
  
  getQuery:  ->
    query = 
      sql: "INSERT INTO #{@model.tableName} SET ?"
      values: @model.body

module.exports = InsertCommand