should = require("should")
express = require("express")
BeeteaOperation = require("../../lib/beetea").Operation
BeeteaCommand = require("../../lib/beetea").Command
DatabaseConnection = require("../../lib/beetea").DatabaseConnection
_ = require("lodash")
# define server base URL


class Command1 extends BeeteaCommand

  getQuery: (results) ->
    return "select id from test"

class Command2 extends BeeteaCommand

  constructor: ->

  getQuery: (results) ->
    return "select name from test"

class ErrorCommand extends BeeteaCommand

  getQuery: (results) ->
    return "query dsdfor error"

describe "AppBot Operation", ->

  before (done) ->
    DatabaseConnection.connect database: "test"

    DatabaseConnection.getConnection()
      .then (connection) ->
        connection.query "create Table IF NOT EXISTS test (id INT , name NVARCHAR(55))" , (error , success) ->
          throw error if error
          return done() if success

  it 'should instantiate an Operation', (done) ->
    operation = new BeeteaOperation()
    done()

  it 'should execute an Operation', (done) ->
    DatabaseConnection.getConnection()
      .then (connection) ->
        operation = new BeeteaOperation(connection)
        operation.commands.push new Command1()
        operation.commands.push new Command2()

        operation.execute()
          .then ->
            #error.should.equal null
            #connection.queries.toString().indexOf("command2").should.be.above -1
            #connection.queries.toString().indexOf("command1").should.be.above -1
            #connection.queries.toString().indexOf("COMMIT").should.be.above -1
            done()

  it 'should throw an error', (done) ->
    connectionPromise = DatabaseConnection.getConnection()
    connectionPromise.then (connection) ->
      #throw error if error
      operation = new BeeteaOperation(connection)
      operation.commands.push new ErrorCommand()
      operation.commands = operation.commands.reverse()
      promise = operation.execute()
      promise.fail (error) ->
        error.should.not.equal null
        done()
        

  after (done) ->
    DatabaseConnection.getConnection()
      .then (connection) ->
        connection.query "drop table test" , (transactionError , success) ->
          throw transactionError if transactionError
          done()
    
