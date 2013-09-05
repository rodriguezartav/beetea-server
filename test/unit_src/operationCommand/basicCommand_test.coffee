should = require("should")
BeeteaOperation = require("../../lib/beetea").Operation
QueryCommand = require("../../lib/beetea").QueryCommand
UpdateCommand = require("../../lib/beetea").UpdateCommand
DeleteCommand = require("../../lib/beetea").DeleteCommand
InsertCommand = require("../../lib/beetea").InsertCommand
DatabaseConnection = require("../../lib/beetea").DatabaseConnection
Model  = require("../../lib/beetea").Model
model = new Model("modelname","BasicModelTable",{})

_ = require("lodash")
# define server base URL

class QueryOperation extends BeeteaOperation
  
  constructor: (@model,connection) ->
    super connection
  
  setCommands: ->
    @commands.push new QueryCommand(@model)

class DeleteOperation extends BeeteaOperation
  
  constructor: (@model,connection) ->
    super connection
  
  setCommands: ->
    @commands.push new DeleteCommand(@model)

class InsertOperation extends BeeteaOperation
  
  constructor: (@model,connection) ->
    super connection
  
  setCommands: ->
    @commands.push new InsertCommand(@model)

class UpdateOperation extends BeeteaOperation

  constructor: (@model,connection) ->
    super connection
  
  setCommands: ->
    @commands.push new UpdateCommand(@model)

describe "Basic Command", ->

  before (done) ->
    DatabaseConnection.connect database: "test"

    DatabaseConnection.getConnection()
      .then (connection) ->
        connection.query "create Table IF NOT EXISTS BasicModelTable (id int AUTO_INCREMENT, name NVARCHAR(55) , PRIMARY KEY (id), lastname NVARCHAR(44) )" , (error , success) ->
          throw error if error
          done()

  it 'should inster an item', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    model.body = { name: "test", lastname: "lastnametest" }
    connectionPromise.then (connection) ->
      operation = new InsertOperation(model,connection)
      promise = operation.execute()
      promise.then (results) ->
        results.results.length.should.equal 1
        done()

  it 'should update the item', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.then (connection) ->
      model.body =  { id: 1 , name: "test3" }
      operation = new UpdateOperation(model,connection)
      promise = operation.execute (error,results) -> 
        throw error if error
        done()

  it 'should query the updated item', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.fail (error) ->
      console.log error
      done()
    connectionPromise.then (connection) ->
      operation = new QueryOperation(model,connection)
      promise = operation.execute (error,results) -> 
        results.results[0].length.should.be.above 0
        for item in results.results[0]
          item.name.should.equal "test3"
          item.lastname.should.equal "lastnametest"
        done()

  it 'should delete the item', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.then (connection) ->
      model.body =  { id: 1 }
      operation = new DeleteOperation(model,connection)
      promise = operation.execute (error,results) -> 
        throw error if error
        done()

  it 'should query an get 0 items', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.fail (error) ->
      console.log error
      done()
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



