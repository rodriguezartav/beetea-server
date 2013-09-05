Command = require("../interface/command")


class QueryCommand extends Command

  constructor: (options) ->
    if options.query
      @query = options
    else
    @model = options
  
  getQuery:  ->
    return @query if @query
    return "select * from #{@model.tableName}"

module.exports = QueryCommand