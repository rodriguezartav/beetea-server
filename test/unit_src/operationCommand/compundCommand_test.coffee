should = require("should")
BeeteaOperation = require("../../lib/beetea").Operation
QueryCommand = require("../../lib/beetea").QueryCommand
DeleteCommand = require("../../lib/beetea").DeleteCommand
InsertCommand = require("../../lib/beetea").InsertCommand
DatabaseConnection = require("../../lib/beetea").DatabaseConnection
Model  = require("../../lib/beetea").Model
model = new Model("modelname","BasicModelTable",{})
BeeteaCommand = require("../../lib/beetea").Command

_ = require("lodash")
# define server base URL

class UpdateCommand extends BeeteaCommand

  constructor: (@model) ->
    @name = "UpdateCommand for #{@model.name}"
  
  getQuery: (results)  ->
    @model.body.otherColumn = "should throw error"
    query = 
      sql: "UPDATE #{@model.tableName} SET ? where id = #{results.insertId}"
      values: @model.body
    return query

class InsertOperation extends BeeteaOperation

  constructor: (@model,connection) ->
    super connection

  setCommands: ->
    @commands.push new InsertCommand(@model)
    @commands.push new UpdateCommand(@model)


class QueryOperation extends BeeteaOperation

  constructor: (@model,connection) ->
    super connection

  setCommands: ->
    @commands.push new QueryCommand(@model)

describe "Compound Command", ->

  before (done) ->
    DatabaseConnection.connect database: "test"

    DatabaseConnection.getConnection()
      .then (connection) ->
        connection.query "create Table IF NOT EXISTS BasicModelTable (id int AUTO_INCREMENT, name NVARCHAR(55) , PRIMARY KEY (id), lastname NVARCHAR(44) )" , (error , success) ->
          throw error if error
          done()

  it 'should rollback insert an item', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    model.body = { name: "test" }
    connectionPromise.then (connection) ->
      operation = new InsertOperation(model,connection)
      promise = operation.execute()
      
      promise.fail (error) ->
        done()

  it 'should query and get 0 items', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.then (connection) ->
      operation = new QueryOperation(model,connection)
      promise = operation.execute (error,results) ->
        results.results[0].length.should.equal 0
        done()

  after (done) ->
    DatabaseConnection.getConnection()
      .then (connection) ->
        connection.query "drop table BasicModelTable" , (transactionError , success) ->
          throw transactionError if transactionError
          done()



