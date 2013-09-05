should = require("should")
BeeteaOperation = require("../../lib/beetea").Operation
QueryCommand = require("../../lib/beetea").QueryCommand
DeleteCommand = require("../../lib/beetea").DeleteCommand
InsertCommand = require("../../lib/beetea").InsertCommand
CustomCommand = require("../../lib/beetea").CustomCommand
DatabaseConnection = require("../../lib/beetea").DatabaseConnection
Model  = require("../../lib/beetea").Model
model = new Model("modelname","BasicModelTable",{})
BeeteaCommand = require("../../lib/beetea").Command

_ = require("lodash")
# define server base URL

class InsertOperation extends BeeteaOperation

  constructor: (@model,connection) ->
    super connection

  setCommands: ->
    @commands.push new InsertCommand(@model)

describe "Custom Command", ->

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
      operation.commands.push new CustomCommand (results) ->
        return "update BasicModelTable set name='test3' where id = #{results.insertId}"
      promise = operation.execute()
      promise.then (results) ->
        done()

  after (done) ->
    DatabaseConnection.getConnection()
      .then (connection) ->
        connection.query "drop table BasicModelTable" , (transactionError , success) ->
          throw transactionError if transactionError
          done()
