should = require("should")
express = require("express")
_ = require("lodash")
# define server base URL

beforeEach ->
  @DatabaseConnection = require("../../lib/beetea").DatabaseConnection

describe "AppBot DatabaseConnection", ->
  it 'should behave as Singleton', ->
    AppbotDatabaseConnection1 = require("../../lib/beetea").DatabaseConnection
    AppbotDatabaseConnection1.connection = "ok"
    AppbotDatabaseConnection2 = require("../../lib/beetea").DatabaseConnection
    AppbotDatabaseConnection2.connection.should.be.equal "ok"

  it "should have a connection pool" , ->
    @DatabaseConnection.connect host: "", user: "" , password: ""
    @DatabaseConnection.pool.should.not.equal null

  it "should try to open a connection from pool" , (done) ->
    
    @DatabaseConnection.getConnection()
      .then (connection) ->
        connection.should.not.be.equal null
        done()
      .fail (error) ->
        console.log error
      
      
