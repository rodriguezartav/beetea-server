Command = require("../interface/command")

class UpdateCommand extends Command

  constructor: (@model) ->
    @name = "InsertCommand for #{@model.name}"
  
  getQuery:  ->
    modelId = @model.body.id
    delete @model.body.id
    query = 
      sql: "UPDATE #{@model.tableName} SET ? where id = #{modelId}"
      values: @model.body
    @model.body.id = modelId
    return query

module.exports = UpdateCommand