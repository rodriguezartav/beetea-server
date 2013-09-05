should = require("should")

express = require("express")

Session = require("../../lib/session")

# define server base URL

beforeEach ->
  @app = express()

describe "Setup Validation", ->
  it 'Should throw exception if first argument is not Connect App', (done) ->
    try
      Session({},[ {name: "session" } ])
    catch error
      error.should.equal "First Argument should be a Connect/Express Application"
    done()
    
  it 'Should throw exception if sessionConfig does not have name property', (done) ->
    try
      Session( @app , [{}] )
    catch error
      error.should.equal "Session Config must contain a name property"
    done()

  it 'Should throw exception if sessionConfig does not have secret property', (done) ->
    try
      Session( @app , [{ name: "session" }] )
    catch error
      error.should.equal "Session Config must contain a secret property"
    done()

  it 'Should accept object insted of array of Session Config', (done) ->
    Session( @app , { name: "session" , secret: "secret" } )
    done()


