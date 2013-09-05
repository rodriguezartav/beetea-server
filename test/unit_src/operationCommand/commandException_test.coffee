should = require("should")
BeeteaOperation = require("../../lib/beetea").Operation
DatabaseConnection = require("../../lib/beetea").DatabaseConnection

_ = require("lodash")
# define server base URL
    
describe "Exceptional Operations", ->

  before (done) ->
    DatabaseConnection.connect database: "test"
    done()

  it 'should pass error in argument', (done) ->
    BeeteaOperation.staticOperation DatabaseConnection, ["select * from tableNotExists"] , (error,success) ->
      error.should.not.equal null
      done()

  it 'should result in success', (done) ->
    BeeteaOperation.staticOperation DatabaseConnection, ["select 1;"] , (error,success) ->
      done()
    
  it 'should catch error in success', (done) ->
    staticPromise= BeeteaOperation.staticOperation DatabaseConnection, ["select * from tableNotExists",""]
    staticPromise.then (results) ->
      throw "error";
    .fail (error) ->
      error.should.equal "error"
      done()
    staticPromise.fail (error) ->
      done()

  it 'should catch error in success', (done) ->
    BeeteaOperation.staticOperation DatabaseConnection, ["select * from tableNotExists"] , (error,success) =>
      error.should.not.be.equal null
      done()