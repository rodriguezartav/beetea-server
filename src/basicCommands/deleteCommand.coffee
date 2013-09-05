Command = require("../interface/command")


class DeleteCommand extends Command

  constructor: (@model) ->
  
  getQuery:  ->
    query = 
      sql: "Delete from #{@model.tableName} where id = ?"
      values: @model.body.id

module.exports = DeleteCommand