should = require("should")
BeeteaOperation = require("../../lib/beetea").Operation
DatabaseConnection = require("../../lib/beetea").DatabaseConnection

_ = require("lodash")
# define server base URL
    
describe "Static Operation", ->

  before (done) ->
    DatabaseConnection.connect database: "test"
    done()

  it 'should perform all tasks', (done) ->
    staticCommands= 
      [
        "create Table IF NOT EXISTS StaticTable (id int AUTO_INCREMENT, name NVARCHAR(55) , PRIMARY KEY (id), lastname NVARCHAR(44) )",
        "insert into StaticTable (name) values ('test')",
        "select * from StaticTable"
      ]

    staticPromise= BeeteaOperation.staticOperation DatabaseConnection,staticCommands
    staticPromise.then (results) ->
      for result in results.results[2]
        result.name.should.equal "test"

      BeeteaOperation.staticOperation DatabaseConnection, ["drop table StaticTable"] , (error,results) ->
        throw error if error
        done()

    staticPromise.fail (error) ->
      done()